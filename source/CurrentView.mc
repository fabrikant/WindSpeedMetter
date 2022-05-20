using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Time;

class CurrentView extends DayViewCommon {

    function initialize(key) {
        DayViewCommon.initialize(key);
    }

    function onUpdate(dc) {
    	DayViewCommon.onUpdate(dc);
        var data = Tools.getStorage(storageKey, null);
        if (data == null){
        	return;
        }
    	var y = bottom + 2;
		
		for (var i = 0; i < FIELDS_COUNT; i++){
    		var value = Tools.getValueByFieldType(Tools.getProperty("FT"+i), data);
    		y =  drawValue(dc, value[0], value[1], y);
		}    	
    }

	function drawValue(dc, value, description, y){
    	var halfX = getDelimiterX(dc);
		var font = Fonts.getFieldsFont();
		var h = dc.getFontHeight(font);
		dc.drawText(halfX-3, y, font, description, Graphics.TEXT_JUSTIFY_RIGHT);
		dc.drawText(halfX+3, y, font, value, Graphics.TEXT_JUSTIFY_LEFT);
		
		return y + h +2;			
	}
}

class CurrenInputDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
	
	function onKey(keyEvent){
		
		var key = keyEvent.getKey();
		if (keyEvent.getKey() == WatchUi.KEY_ENTER){
			showMenuDaily();
		}else if (keyEvent.getKey() == WatchUi.KEY_UP){
			showMenuDaily();
		}else if (keyEvent.getKey() == WatchUi.KEY_DOWN){
			showMenuHourly();
		}else{
			System.exit();
		}
		return false;
	}
	
	function showMenuHourly(){
		if (System.getSystemStats().totalMemory > 62000){
			WatchUi.pushView(new WeatherMenuHourly(), new EmptyDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}else{
			WatchUi.pushView(new WeatherMenuDaily(), new WeatherMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}    	
	}
	
	function onTap(clickEvent){
		showMenuDaily();
		return false;
	}
	
	function showMenuDaily(){
		WatchUi.pushView(new WeatherMenuDaily(), new WeatherMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}
}
