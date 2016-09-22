.hspage{
width:100%;
border:solid 1px #e9e9e9 !important;
}
.hs-iframe-page {
width:100%;
}
.hsheader{
background-color:#444;
padding: 5px 5px 2px 10px;
}

.hsbody{
padding:0px 5px 0px 5px;
}

.hsitem{
padding:0px 0px 2px 0px;

font-size: 11px;
}

.hsitem .hslabel{
text-align:right;
width:110px;
margin-bottom:0px;
}

.hsitem .hsdata{
width:150px;
padding-left:5px;
}

.hsitem label{
font-weight:bold;
text-align:right;
}

.hsitem span{
font-size:12px;
}

.hsIntelColumn{
float:left;
margin-right:15px;
}

.hsClear{
clear:both;
}

h2{
color: #424242;
display: block !important;
font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
font-size: 13px !important;
font-weight: bold;
padding:2px 0px 2px 0px;
}

h1{
color: #FE7722;
display: block;
font-family: Helvetica, Arial, sans-serif;
font-size: 25px !important;
font-weight: 100;
height: 25px;
 
}

.testing{
background:#e9e9e9;
}

.hstable{
	border:0px;
	border-collapse: collapse;
	-webkit-border-horizontal-spacing: 0px;
-webkit-border-vertical-spacing: 0px;
font-family: verdana, arial, sans-serif !important;
font-size: 13px !important;
font-weight:normal;
}

.hsthead, .hstfoot{
	background-color: #555;
	color:#fff;
	border-right-color: #666;
  border-right-style: solid;
  border-right-width: 1px;
  height: 30px;
  padding:5px 30px 5px 30px;
  font-family: verdana, arial, sans-serif;
  font-size: 13px;

}

.hstr-even{

}

.hstr-odd{
	height: 25px;
}
.hstd{
	padding:10px 10px 10px 10px;
	  font-family: verdana, arial, sans-serif;
  font-size: 13px;
}

.hslink{
	color:#589CEB; 
	text-decoration:none;
}

/*
 *  File:         demo_table.css
 *  CVS:          $Id$
 *  Description:  CSS descriptions for DataTables demo pages
 *  Author:       Allan Jardine
 *  Created:      Tue May 12 06:47:22 BST 2009
 *  Modified:     $Date$ by $Author$
 *  Language:     CSS
 *  Project:      DataTables
 *
 *  Copyright 2009 Allan Jardine. All Rights Reserved.
 *
 * ***************************************************************************
 * DESCRIPTION
 *
 * The styles given here are suitable for the demos that are used with the standard DataTables
 * distribution (see www.datatables.net). You will most likely wish to modify these styles to
 * meet the layout requirements of your site.
 *
 * Common issues:
 *   'full_numbers' pagination - I use an extra selector on the body tag to ensure that there is
 *     no conflict between the two pagination types. If you want to use full_numbers pagination
 *     ensure that you either have "example_alt_pagination" as a body class name, or better yet,
 *     modify that selector.
 *   Note that the path used for Images is relative. All images are by default located in
 *     ../images/ - relative to this CSS file.
 */
 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * DataTables features
 */
 
.dataTables_wrapper {
	position: relative;
	min-height: 302px;
	clear: both;
	_height: 302px;
	zoom: 1; /* Feeling sorry for IE */
}
 
.dataTables_processing {
	position: absolute;
	top: 50%;
	left: 50%;
	width: 250px;
	height: 30px;
	margin-left: -125px;
	margin-top: -15px;
	padding: 14px 0 2px 0;
	border: 1px solid #ddd;
	text-align: center;
	color: #999;
	font-size: 14px;
	background-color: white;
}
 
.dataTables_length {
	width: 40%;
	float: left;
}
 
.dataTables_filter {
	width: 50%;
	float: right;
	text-align: right;
}
 
.dataTables_info {
	width: 60%;
	float: left;
}
 
.dataTables_paginate {
	width: 44px;
	* width: 50px;
	float: right;
	text-align: right;
}
 
/* Pagination nested */
.paginate_disabled_previous, .paginate_enabled_previous, .paginate_disabled_next, .paginate_enabled_next {
	height: 19px;
	width: 19px;
	margin-left: 3px;
	float: left;
}
 

 
 
 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * DataTables display
 */
table.display {
	margin: 0 auto;
	clear: both;
	width: 100%;
	
	/* Note Firefox 3.5 and before have a bug with border-collapse
	 * ( https://bugzilla.mozilla.org/show%5Fbug.cgi?id=155955 ) 
	 * border-spacing: 0; is one possible option. Conditional-css.com is
	 * useful for this kind of thing
	 *
	 * Further note IE 6/7 has problems when calculating widths with border width.
	 * It subtracts one px relative to the other browsers from the first column, and
	 * adds one to the end...
	 *
	 * If you want that effect I'd suggest setting a border-top/left on th/td's and 
	 * then filling in the gaps with other borders.
	 */
}
 
table.display thead th {
	padding: 3px 18px 3px 10px;
	border-bottom: 1px solid black;
	font-weight: bold;
	cursor: pointer;
	* cursor: hand;
}
 
table.display tfoot th {
	padding: 3px 18px 3px 10px;
	border-top: 1px solid black;
	font-weight: bold;
}
 
table.display tr.heading2 td {
	border-bottom: 1px solid #aaa;
}
 
table.display td {
	padding: 3px 10px;
}
 
table.display td.center {
	text-align: center;
} 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * DataTables row classes
 */
table.display tr.odd.gradeA {
	background-color: #ddffdd;
}
 
table.display tr.even.gradeA {
	background-color: #eeffee;
}
 
table.display tr.odd.gradeC {
	background-color: #ddddff;
}
 
table.display tr.even.gradeC {
	background-color: #eeeeff;
}
 
table.display tr.odd.gradeX {
	background-color: #ffdddd;
}
 
table.display tr.even.gradeX {
	background-color: #ffeeee;
}
 
table.display tr.odd.gradeU {
	background-color: #ddd;
}
 
table.display tr.even.gradeU {
	background-color: #eee;
}
 
 
tr.odd {
	background-color: rgb(245,245,245);

}
 
tr.even {
	background-color: white;
  height: 25px;
}
 
 
 
 
 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Misc
 */
.dataTables_scroll {
	clear: both;
}
 
.dataTables_scrollBody {
	*margin-top: -1px;
}
 
.top, .bottom {
	padding: 15px;
	background-color: #fff;
	border: 0px solid #fff;
}
 
.top .dataTables_info {
	float: none;
}
 
.clear {
	clear: both;
}
 
.dataTables_empty {
	text-align: center;
}
 
tfoot input {
	margin: 0.5em 0;
	width: 100%;
	color: #444;
}
 
tfoot input.search_init {
	color: #999;
}
 
td.group {
	background-color: #d1cfd0;
	border-bottom: 2px solid #A19B9E;
	border-top: 2px solid #A19B9E;
}
 
td.details {
	background-color: #d1cfd0;
	border: 2px solid #A19B9E;
}
 
 
.example_alt_pagination div.dataTables_info {
	width: 40%;
}
 
.paging_full_numbers {
	width: 400px;
	height: 22px;
	line-height: 22px;
}
 
.paging_full_numbers span.paginate_button,
 	.paging_full_numbers span.paginate_active {
	border: 1px solid #aaa;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	padding: 2px 5px;
	margin: 0 3px;
	cursor: pointer;
	*cursor: hand;
}
 
.paging_full_numbers span.paginate_button {
	background-color: #ddd;
}
 
.paging_full_numbers span.paginate_button:hover {
	background-color: #ccc;
}
 
.paging_full_numbers span.paginate_active {
	background-color: #99B3FF;
}
 
table.display tr.even.row_selected td {
	background-color: #B0BED9;
}
 
table.display tr.odd.row_selected td {
	background-color: #9FAFD1;
}
 
 
/*
 * Sorting classes for columns
 */
/* For the standard odd/even */
tr.odd td.sorting_1 {
	background-color: #D3D6FF;
}
 
tr.odd td.sorting_2 {
	background-color: #DADCFF;
}
 
tr.odd td.sorting_3 {
	background-color: #E0E2FF;
}
 
tr.even td.sorting_1 {
	background-color: #EAEBFF;
}
 
tr.even td.sorting_2 {
	background-color: #F2F3FF;
}
 
tr.even td.sorting_3 {
	background-color: #F9F9FF;
}
 
 
/* For the Conditional-CSS grading rows */
/*
 	Colour calculations (based off the main row colours)
  Level 1:
		dd > c4
		ee > d5
	Level 2:
	  dd > d1
	  ee > e2
 */
tr.odd.gradeA td.sorting_1 {
	background-color: #c4ffc4;
}
 
tr.odd.gradeA td.sorting_2 {
	background-color: #d1ffd1;
}
 
tr.odd.gradeA td.sorting_3 {
	background-color: #d1ffd1;
}
 
tr.even.gradeA td.sorting_1 {
	background-color: #d5ffd5;
}
 
tr.even.gradeA td.sorting_2 {
	background-color: #e2ffe2;
}
 
tr.even.gradeA td.sorting_3 {
	background-color: #e2ffe2;
}
 
tr.odd.gradeC td.sorting_1 {
	background-color: #c4c4ff;
}
 
tr.odd.gradeC td.sorting_2 {
	background-color: #d1d1ff;
}
 
tr.odd.gradeC td.sorting_3 {
	background-color: #d1d1ff;
}
 
tr.even.gradeC td.sorting_1 {
	background-color: #d5d5ff;
}
 
tr.even.gradeC td.sorting_2 {
	background-color: #e2e2ff;
}
 
tr.even.gradeC td.sorting_3 {
	background-color: #e2e2ff;
}
 
tr.odd.gradeX td.sorting_1 {
	background-color: #ffc4c4;
}
 
tr.odd.gradeX td.sorting_2 {
	background-color: #ffd1d1;
}
 
tr.odd.gradeX td.sorting_3 {
	background-color: #ffd1d1;
}
 
tr.even.gradeX td.sorting_1 {
	background-color: #ffd5d5;
}
 
tr.even.gradeX td.sorting_2 {
	background-color: #ffe2e2;
}
 
tr.even.gradeX td.sorting_3 {
	background-color: #ffe2e2;
}
 
tr.odd.gradeU td.sorting_1 {
	background-color: #c4c4c4;
}
 
tr.odd.gradeU td.sorting_2 {
	background-color: #d1d1d1;
}
 
tr.odd.gradeU td.sorting_3 {
	background-color: #d1d1d1;
}
 
tr.even.gradeU td.sorting_1 {
	background-color: #d5d5d5;
}
 
tr.even.gradeU td.sorting_2 {
	background-color: #e2e2e2;
}
 
tr.even.gradeU td.sorting_3 {
	background-color: #e2e2e2;
}
 
 
/*
 * Row highlighting example
 */
.ex_highlight #example tbody tr.even:hover, #example tbody tr.even td.highlighted {
	background-color: #ECFFB3;
}
 
.ex_highlight #example tbody tr.odd:hover, #example tbody tr.odd td.highlighted {
	background-color: #E6FF99;
}
 
.ex_highlight_row #example tr.even:hover {
	background-color: #ECFFB3;
}
 
.ex_highlight_row #example tr.even:hover td.sorting_1 {
	background-color: #DDFF75;
}
 
.ex_highlight_row #example tr.even:hover td.sorting_2 {
	background-color: #E7FF9E;
}
 
.ex_highlight_row #example tr.even:hover td.sorting_3 {
	background-color: #E2FF89;
}
 
.ex_highlight_row #example tr.odd:hover {
	background-color: #E6FF99;
}
 
.ex_highlight_row #example tr.odd:hover td.sorting_1 {
	background-color: #D6FF5C;
}
 
.ex_highlight_row #example tr.odd:hover td.sorting_2 {
	background-color: #E0FF84;
}
 
.ex_highlight_row #example tr.odd:hover td.sorting_3 {
	background-color: #DBFF70;
}
 
 
/*
 * KeyTable
 */
table.KeyTable td {
	border: 3px solid transparent;
}
 
table.KeyTable td.focus {
	border: 3px solid #3366FF;
}
 
table.display tr.gradeA {
	background-color: #eeffee;
}
 
table.display tr.gradeC {
	background-color: #ddddff;
}
 
table.display tr.gradeX {
	background-color: #ffdddd;
}
 
table.display tr.gradeU {
	background-color: #ddd;
}
 
div.box {
	height: 100px;
	padding: 10px;
	overflow: auto;
	border: 1px solid #8080FF;
	background-color: #E5E5FF;
}

 * jQuery UI Tabs 1.8.14
 *
 * Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * http://docs.jquery.com/UI/Tabs#theming
 */
.ui-tabs { position: relative; padding: .2em; zoom: 1; } /* position: relative prevents IE scroll bug (element with position: relative inside container with overflow: auto appear as "fixed") */
.ui-tabs .ui-tabs-nav { margin: 0; padding: .2em .2em 0; }
.ui-tabs .ui-tabs-nav li { list-style: none; float: left; position: relative; top: 1px; margin: 0 .2em 1px 0; border-bottom: 0 !important; padding: 0; white-space: nowrap; }
.ui-tabs .ui-tabs-nav li a { float: left; padding: .5em 1em; text-decoration: none; }
.ui-tabs .ui-tabs-nav li.ui-tabs-selected { margin-bottom: 0; padding-bottom: 1px; }
.ui-tabs .ui-tabs-nav li.ui-tabs-selected a, .ui-tabs .ui-tabs-nav li.ui-state-disabled a, .ui-tabs .ui-tabs-nav li.ui-state-processing a { cursor: text; }
.ui-tabs .ui-tabs-nav li a, .ui-tabs.ui-tabs-collapsible .ui-tabs-nav li.ui-tabs-selected a { cursor: pointer; } /* first selector in group seems obsolete, but required to overcome bug in Opera applying cursor: text overall if defined elsewhere... */
.ui-tabs .ui-tabs-panel { display: block; border-width: 0; padding: 1em 1.4em; background: none; }
.ui-tabs .ui-tabs-hide { display: none !important; }
.ui-tabs-nav li.ui-tabs-selected a,.ui-tabs-nav li.ui-tabs-selected a:hover{color:#FE7722;}
.ui-tabs-nav li a {
	color:;#424242
display: block !important;
font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
font-size: 14px !important;
font-weight: bold;
padding:5px 0px 5px 0px;	
}
.ui-tabs-nav li a:hover {color:#589CEB;}

