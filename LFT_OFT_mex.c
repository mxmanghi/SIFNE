// Copyright (c) 2016.
// All rights reserved. Please read the 'license.txt' for license terms.
// 
// Developers: Zhen Zhang, Pakorn Kanchanawong
// Contact: biekp@nus.edu.sg
// 
// Reference:
// Sandberg, K. & Brega, M. Segmentation of thin structures in electron micrographs using orientation fields. J Struct Biol 157, 403-415 (2007). 
#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <unistd.h>

# define PI 3.141593

#define printfFcn(...) { mexPrintf(__VA_ARGS__); mexEvalString("pause(.001);"); } 
extern bool ioFlush(void);

/* { mexPrintf(__VA_ARGS__); mexEvalString("drawnow;('update')"); } */

void Enhancement(double *Img, double *EImg, double *LFT_Img, double *LFT_Orientations, int H, int W, int R, double Nangles, double *ROIMask)
{
    int i,j,x,y,MaxIndex;
    double q;
    double k, AngleInterval, Rho, Theta;
    double MaxAngleIntensity, LineSum, MaxIntensityAngle;
    int imgHeight;
    int imgWidth;

    AngleInterval = PI/Nangles;
    imgHeight = H - R;
    imgWidth  = W - R;
    // LFT
    printfFcn("Computing the LFT...\n");

    for(i=R; i<imgWidth; i++)
    {
        for(j=(int)R; j<imgHeight; j++)
        {   
            if (ROIMask[(i*(int)H + j)]==1.0)
            {
                MaxAngleIntensity = 0;
                MaxIntensityAngle = 0;
                for(k=-PI/2.0; k<PI/2.0; k=k+AngleInterval)
                {
                    LineSum = 0;
                    for(q=-R;q<(R+1);q++)
                    {
                        x = i + (int)floor(q * cos(k)+0.5);
                        y = j - (int)floor(q * sin(k)+0.5);
                        if(x<0)     x=0;
                        if(y<0)     y=0;
                        if(x>(W-1)) x=W-1;
                        if(y>(H-1)) y=H-1;
                        LineSum = LineSum + Img[(x*(int)H + y)];
                    }
                    if(MaxAngleIntensity<LineSum) 
                    {
                        MaxAngleIntensity = LineSum;
                        MaxIntensityAngle = k;
                    }
                }
                LFT_Img[i*H + j] = MaxAngleIntensity/(R+R+1);
                LFT_Orientations[i*H + j] = MaxIntensityAngle;
            }
        }
        printfFcn("%d",i % 10);
        if ((i%100) == 0) {
            printfFcn("\n");
        }
    }
    if ((i%100) > 0) {
        printfFcn("\n"); 
    }
    // OFT
    printfFcn("Computing the OFT...\n");
    for(i=R; i<imgWidth; i++)
    {
        for(j=R; j<imgHeight; j++)
        {
            if (ROIMask[(i*H + j)]==1.0)
            {
                MaxAngleIntensity = 0;
                for(k=-PI/2; k<PI/2; k=k+AngleInterval)
                {
                    LineSum = 0;
                    for(q=-R; q<R+1; q++)
                    {
                        Rho = LFT_Img[i*H + j];
                        x = i + (int)floor(q*cos(k)+0.5);
                        y = j - (int)floor(q*sin(k)+0.5);
                        if(x<0)     x=0;
                        if(y<0)     y=0;
                        if(x>(W-1)) x=W-1;
                        if(y>(H-1)) y=H-1;
                        Theta = LFT_Orientations[x*H + y];
                        LineSum = LineSum + Rho * cos(2*(Theta-k));
                    }
                    if(MaxAngleIntensity<LineSum) MaxAngleIntensity = LineSum;
                }
                EImg[i*H + j] = MaxAngleIntensity;
            }
        }
        printfFcn("%d",i % 10);
        if ((i%100) == 0) {
            printfFcn("\n");
        }
    }
    if ((i%100) > 0) { printfFcn("\n"); 
    }
}


void Initialization(double *Img, double *EImg, double *LFT_Img, double *LFT_Orientations, int H, int W, double R, double Nangles, double *ROIMask)
{
    double dim[2];
    
    dim[0] = H;
    dim[1] = W;
    
    Enhancement(Img, EImg, LFT_Img, LFT_Orientations, H, W, (int)floor(R), Nangles, ROIMask);
    
}

void mexFunction(int iNbOut, mxArray *pmxOut[], int iNbIn,  const mxArray *pmxIn[])
{
    #define InputImg                 pmxIn[0]
    #define pR                       pmxIn[1]
    #define pNangles                 pmxIn[2]  
    #define ROI                      pmxIn[3] 
    #define OutputImg                pmxOut[0]  
    #define LFT_IntensityMap         pmxOut[1]
    #define LFT_OrientationMap       pmxOut[2]
            
    double *Rad = mxGetPr(pR);
    double *Nofangles = mxGetPr(pNangles);
    
    LFT_IntensityMap =   mxCreateNumericArray(mxGetNumberOfDimensions(InputImg),mxGetDimensions(InputImg),mxDOUBLE_CLASS, mxREAL); 
    LFT_OrientationMap = mxCreateNumericArray(mxGetNumberOfDimensions(InputImg),mxGetDimensions(InputImg),mxDOUBLE_CLASS, mxREAL); 
    OutputImg      =     mxCreateNumericArray(mxGetNumberOfDimensions(InputImg),mxGetDimensions(InputImg),mxDOUBLE_CLASS, mxREAL); 
    
    Initialization(mxGetPr(InputImg), mxGetPr(OutputImg), mxGetPr(LFT_IntensityMap), mxGetPr(LFT_OrientationMap), mxGetM(OutputImg), mxGetN(OutputImg), *Rad, *Nofangles, mxGetPr(ROI));
}


