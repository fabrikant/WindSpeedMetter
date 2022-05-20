using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Math;

class DayViewCommon extends WatchUi.View {

	var storageKey;
	var bottom;
	var weatherForecast;
	
    function initialize(key) {
    	storageKey = key;
        View.initialize();
    }

     function onShow() {
     
       	var location = Activity.getActivityInfo().currentLocation;
       	weatherForecast = new WeatherForecast();
    	if (location != null) {
			location = location.toDegrees();
			var lat = location[0].toFloat();
			var lon = location[1].toFloat();
			if (!lat.equals(0.0) && !lon.equals(0.0)){
				Tools.setProperty("Lat", lat);
				Tools.setProperty("Lon", lon);
				weatherForecast.setCoord();
			}
		}
		weatherForecast.startRequest(storageKey, self.method(:onWeatherUpdate));    	
    }
    
    function onUpdate(dc) {
        dc.setColor(Tools.getBackgroundColor(), Tools.getBackgroundColor());
        dc.clear();
        var data = Tools.getStorage(storageKey, null);
        if (data == null){
        	return;
        }
        dc.setColor(Tools.getForegroundColor(), Graphics.COLOR_TRANSPARENT);
        var iconName = data["weather"][0]["icon"];
        var size = 2;
        var res = Tools.getStorage(iconName+size.format("%d"), null);
        var halfX = dc.getWidth()/2;
        var y = 0; 
        if (res != null){
        	dc.drawBitmap(halfX-res.getWidth()/2, y, res);
        	y = y + res.getHeight();
        }else{
        	weatherForecast.startRequestImage(iconName, size);
        	y = y + System.getDeviceSettings().screenHeight/3;
        }
        
        y = y - 15;
        var font = Graphics.FONT_XTINY;
       	
       	//description
       	var r = System.getDeviceSettings().screenWidth/2;
       	var x = r - Math.sqrt(Math.pow(r, 2)-Math.pow(r - y, 2));
       	dc.drawText(x, y, font, data["weather"][0]["description"], Graphics.TEXT_JUSTIFY_LEFT);
       	y = y + dc.getFontHeight(font);
       	
       	font = Graphics.FONT_NUMBER_HOT;
       	var temp = data["temp"];
       	if (temp instanceof Lang.Dictionary){
       		temp = temp["day"];
       	}
       	dc.setColor(ToolsGlance.getTempColor(temp) , Graphics.COLOR_TRANSPARENT);
       	dc.drawText(halfX/2, y, font,temp.format("%d")+"°", Graphics.TEXT_JUSTIFY_CENTER);
       	var h = dc.getFontHeight(font);
       	bottom = y + h+2;
       
		var w = h; 
       	var wind = new WindDirectionField({:x => halfX, :y => y, :h => h, :w => w, :color => Tools.getWindColor(data["wind_speed"])});
       	wind.draw(dc, data["wind_deg"]);
       	
     	font = Graphics.FONT_SYSTEM_SMALL;
       	var wSpeed = Tools.windSpeedConvert(data["wind_speed"]);
       	x = dc.getWidth()- 5 - Tools.max(dc.getTextWidthInPixels(wSpeed[:valueString], font), dc.getTextWidthInPixels(wSpeed[:unit], font));
       	dc.drawText(x, y, font,wSpeed[:valueString], Graphics.TEXT_JUSTIFY_LEFT);
       	dc.drawText(x, y + dc.getFontHeight(font), font, wSpeed[:unit], Graphics.TEXT_JUSTIFY_LEFT);
       	
       	dc.setColor(Tools.getForegroundColor(), Graphics.COLOR_TRANSPARENT);
       	dc.drawLine(0, bottom, dc.getWidth(), bottom);
       	dc.drawLine(getDelimiterX(dc), bottom, getDelimiterX(dc), dc.getHeight());
       	 
    }
	
	function getDelimiterX(dc){
		return dc.getWidth().toFloat()/100*Tools.getProperty("FieldsDelimiter");	
	}
	function onWeatherUpdate(code, data){
		if (code == 200){
			Tools.setStorage(storageKey, data[storageKey]);
			globalCache[storageKey] = data[storageKey];
			WatchUi.requestUpdate();
		}
	}

}
