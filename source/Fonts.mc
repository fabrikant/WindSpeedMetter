using Toybox.System;
using Toybox.Graphics;

module Fonts{
	
	(:regularVersion)
	function getFieldsFont(){
		return Graphics.FONT_SYSTEM_TINY;
	}
	
	(:smallFontVersion)
	function getFieldsFont(){
		return Graphics.FONT_SYSTEM_XTINY;
	}
	
	(:notVivoactive3)
	function getMenuListFont(){
		return Graphics.FONT_SYSTEM_TINY;
	}

	(:vivoactive3)
	function getMenuListFont(){
		return Graphics.FONT_SYSTEM_XTINY;
	}
}