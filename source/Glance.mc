using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.Application;

(:glance)
class WeatherGlanceView extends WatchUi.GlanceView {

	function initialize() {
    	GlanceView.initialize();
	}

     function onShow() {
    }

	function onUpdate(dc) {
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		var storageKey = getDataStorageKey();
        var data = null;
        
        if (storageKey != null){ 
        	data = Application.Storage.getValue(storageKey);
        }
        
        if (data == null){
        	dc.drawText(
        		dc.getWidth()/2, 
        		dc.getHeight()/2, 
        		Graphics.FONT_GLANCE, 
        		"NO DATA", 
        		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        	return;
        }

//        var info = Toybox.Time.Gregorian.info(new Toybox.Time.Moment(storageKey), Toybox.Time.FORMAT_SHORT);
//        System.println(info.day+"."+info.month+"."+info.year+" "+info.hour+":"+info.min);
//        System.println(data);
        
        var interval = 10;
		var x = 10;
		
		var res = Application.Storage.getValue(data["icon"]+1);
        if (res != null){
        	dc.drawBitmap(0, (dc.getHeight()-res.getHeight())/2, res);
        	x = x + res.getWidth();
        }
		
		var tmp = "°C";
		if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE){
			tmp = "°F";
		}
		var font = Graphics.FONT_GLANCE;
		tmp = data["temp"].format("%d")+tmp;
		dc.drawText(x, dc.getHeight()/2, font, tmp, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		
		x += dc.getTextWidthInPixels(tmp, font)+interval;
		var h = dc.getFontHeight(font);
		var windColor = Graphics.COLOR_WHITE;
		if (Application.Properties.getValue("WindAutocolor")){
			windColor = ToolsGlance.getWindColor(data["wind_speed"]);
		}
		var wind = new WindDirectionField({:x => x, :y => (dc.getHeight() - h)/2, :h => h, :w => h, :color => windColor});
       	wind.draw(dc, data["wind_deg"]);
		
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		
		x += h;
		var wSpeed = ToolsGlance.windSpeedConvert(data["wind_speed"]);
		//tmp = wSpeed[:valueString]+" "+wSpeed[:unit];
		tmp = wSpeed[:valueString];
		dc.drawText(x, dc.getHeight()/2, font, tmp, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	}
	
	function getDataStorageKey(){
		
		var res = null;
		
		var keys = Application.Storage.getValue(STORAGE_KEY_HOURLY+STORAGE_KEY_GLANCE);
		var newAr = Application.Storage.getValue(STORAGE_KEY_DAILY+STORAGE_KEY_GLANCE);
		if (newAr != null){
			if (keys == null){
				keys = Application.Storage.getValue(STORAGE_KEY_DAILY+STORAGE_KEY_GLANCE);
			}else{
				keys.addAll(newAr);
			}
		}
	
		if (keys != null){
			var now = Toybox.Time.now();
			for (var i = 0; i < keys.size(); i++){
				if (now.lessThan(new Toybox.Time.Moment(keys[i]))){
					res = keys[i];
					break;
				}
			}
		}
		return res;
	}
}