/*Standard libraries that are required for math, output, etc.*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "functions.h"

/*The assembly program that will be tested and compared against the standard library function*/

void selecttest() {
    /*The variables are, in order, worst speed, the index of the worst speed, worst error, the 
    index of the worst error, a temporary variable for test cases generated from the variable;
    such as i, i +- epsilon. */
    double worstSpeed = 0, indexSpeed, worstError = 0, indexError, tmp;

    /* Accessing the input file */
    FILE *in;
    in = fopen("SelectionInput.txt", "r");

    /* Creating the output file */
    FILE *fp;
    fp = createFile("Select_Test_");

    /*This is the top row of our csv file which will record all tests according to the used
    program's specifications (speed only records speed, error only records error, both records
    both speed and error for standard library and our assembly program's results)*/
    fprintf(fp, "Test Var,Our Output,Std Output,The Deviation Was,");
    fprintf(fp, "Our Output (in ms),Std Output (in ms),We Took X Ms Longer\n");

    /* All values in SelectionInput.txt are tested*/
    char entry[1000];
    while (fgets(entry, 1000, in)!=NULL) {
        testCase(strtod(entry, NULL), &worstSpeed, &indexSpeed, &worstError, &indexError, fp);
    }
    /* The file is closed to avoid leaks and to make sure the whole stream is written */
    fclose(fp);
    /* The worst error rate and its index is displayed on the console */
    printf("The worst diviation from the c sinh function is %e with input %e\n", worstError, indexError);
    /* The worst speed difference and its index is displayed on the console */
    //printf("the speed is %e at %e\n", worstSpeed, indexSpeed);
}
