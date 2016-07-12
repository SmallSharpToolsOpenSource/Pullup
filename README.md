# Pullup

<div style="float:right;margin:0 0 20px 0" markdown="1">
![GIF](Pullup.gif)
</div>

Pullup UI which allows for a full screen UI which is pulled up from the bottom. The summary view appears at the bottom and can be expanded by either tapping or pulling it up. Items can scroll horizontally while details for an item can be scrolled vertically once the view is expanded.

The purpose of this UI is to make more content available on a single screen. A map view could be the primary view below these overlays. The detail content displayed in a table view belo the draggable header can include various kinds of content which can be interactive.

The detail disclosure button in the draggable header demonstrates that it is possible to tap a button and get the numbered item.

## View Hierarchy and Communication

The view hierarchy is a composition of various view controllers which manage a view which is embedded in the main view. Actions which are related to views in the main view will need to be communicated. Relaying changes can be done using delegation or notifications. Since the view hierarchy has many layers it would required many delegates which makes it a most costly option than simply posting notifications from a subcontroller which the main controller is observing. It is also possible to share a single delegate instance with all subcontrollers which will pass along updates to the main controller. There are many options.

## License

Pullup is available under the MIT license. See the LICENSE file for more info.

## Contact

Brennan Stehling  
[SmallSharpTools](http://www.smallsharptools.com/)  
[@smallsharptools](https://twitter.com/smallsharptools) 
