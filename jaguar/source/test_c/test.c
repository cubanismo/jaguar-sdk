
/********************************************************************************/
/* This is a simple, no-real-purpose C source code file designed to test the    */
/* proper setup and operation of the GCC C compiler. See the included MAKEFILE  */
/* for an example of calling GCC from MAKE.                                     */
/********************************************************************************/

int y;

void foo(int i, int j)
{
	if (i >= j)
		j = i + 34;

	y = j;
}


short foo1(void)
{
short local=0,test;

	local +=321;
	test = (local-1)/11;
	return (test);
}
