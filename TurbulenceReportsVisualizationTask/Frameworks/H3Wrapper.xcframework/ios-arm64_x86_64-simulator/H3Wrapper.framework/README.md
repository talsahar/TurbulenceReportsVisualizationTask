## Update H3 lib

1. Go to Uber's [h3 releases page](https://github.com/uber/h3/releases)
2. Download the latest version source code zip
3. Replace folders as follows
	
	`[new_ver]/scr/h3lib/include` ---> `[sdk]/Vendor/h3lib/include`
	
	`[new_ver]/scr/h3lib/lib` ---> `[sdk]/Vendor/h3lib/lib`
	
4. CAREFULLY review changes in Git and keep the custom changes including the following:

	- `h3lib/include/constants.h` commented out part to avoid errors/warnings
	
		```
		//#ifndef M_PI
		///** pi */
		//#define M_PI 3.14159265358979323846
		//#endif
		//
		//#ifndef M_PI_2
		///** pi / 2.0 */
		//#define M_PI_2 1.5707963267948966
		//#endif
		```
		
	- `h3lib/include/h3api.h` exposed internal functions from `linkedGeo.h`

		```
		int countLinkedPolygons(LinkedGeoPolygon *polygon);
		int countLinkedLoops(LinkedGeoPolygon *polygon);
		int countLinkedCoords(LinkedGeoLoop *loop);
		void destroyLinkedGeoLoop(LinkedGeoLoop *loop);
		```
	
	- `h3lib/include/linkedGeo.h` commented functions that are exposed in `h3api.h`

		```
		//int countLinkedPolygons(LinkedGeoPolygon *polygon);
		//int countLinkedLoops(LinkedGeoPolygon *polygon);
		//int countLinkedCoords(LinkedGeoLoop *loop);
		//void destroyLinkedGeoLoop(LinkedGeoLoop *loop);
		```
		
5. Remove reference `Vendors/h3lib` in the SDK Xcode project and add `Vendors/h3lib` again to make sure all new files are added to the project. (Remove licence and readme files from the project)

6. Make `h3api.h` as `Public` instead of `Project` by selecting it in the `File Inspector` of the file (on the right).

7. Run and make sure all is ok. 