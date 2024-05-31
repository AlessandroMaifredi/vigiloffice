#include <ArduinoJson.h>

String createSingleLampEditPage(JsonDocument doc) {
    JsonArray sensors = doc["sensors"].as<JsonArray>();
    JsonObject flameSensor;
    JsonObject lightSensor;
    JsonObject motionSensor;
    JsonObject rgb;
    for(JsonVariant v : sensors){
      JsonObject obj = v.as<JsonObject>();
      if(obj[SENSOR_NAME_JSON_NAME] == LIGHT_JSON_NAME){
         lightSensor = obj;
      } else if(obj[SENSOR_NAME_JSON_NAME] == MOTION_JSON_NAME){
          motionSensor = obj;
      } else if(obj[SENSOR_NAME_JSON_NAME] == FLAME_JSON_NAME){
        flameSensor = obj;
      }else if(obj[SENSOR_NAME_JSON_NAME] == RGB_JSON_NAME){
        rgb = obj;
      }
    }
    JsonObject alarm = doc[ALARM_JSON_NAME].as<JsonObject>();


    String page = "<!doctype html>"
"<html lang='en'>"
"<head>"
"  <meta charset='utf-8'>"
"  <meta name='viewport' content='width=device-width, initial-scale=1'>"
"  <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet' integrity='sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3' crossorigin='anonymous'>"
"  <style>"
"    .form-group {"
"      margin-bottom: 1rem;"
"    }"
"    label {"
"      font-size: 1.25rem;"
"    }"
"    .sensor-group {"
"      border: 1px solid #dee2e6;"
"      padding: 15px;"
"      border-radius: 5px;"
"      margin-bottom: 20px;"
"    }"
"    .sensor-group h2 {"
"      margin-bottom: 20px;"
"    }"
"  </style>"
"  <title>Bootstrap Form</title>"
"  <script>"
"      var currentLightValue = 125;"
"  </script>"
"</head>"
"<body>"
"  <div class='container py-5'>"
"    <h1 class='mb-5 text-center'>Sensor Management</h1>"
"    <form id='myForm' class='mx-auto'>"
"        <input type='hidden' value='" + String(doc["mac-address"]) + "' name='mac' id='mac' >"
"      <div class='row'>"
"        <div class='col'>"
"          <div class='sensor-group'>"
"            <h2>Flame Sensor</h2>"
"            <!-- Flame Sensor fields -->"
"            <div class='form-group'>"
"                <label for='flameIntervalSlider'>Light reading interval</label>"
"                <span id='flameIntervalSlider' class='d-block text-muted mb-2'>Current: " + String(flameSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "</span>"
"                <input type='range' class='form-control-range mb-3' id='flameIntervalSlider' name='flameIntervalSlider' min='1000' max='60000' step='250' value='"+ String(flameSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "'>"
"                <input type='number' class='form-control' id='flameIntervalSliderInput' name='flameIntervalSliderInput' min='1000' max='60000' step='250' value='"+ String(flameSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "'>"
"                <div class='invalid-feedback'>Please adjust the slider within the range of 1000 to 60000.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label>Status</label>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='flameStatus' id='flameEnabled' value='true'" + (flameSensor[SENSOR_STATUS_JSON_NAME] == true ? "checked" : "") + ">"
"                    <label class='form-check-label' for='flameEnabled'>Enabled</label>"
"                </div>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='flameStatus' id='flameDisabled' value='false'"+ (flameSensor[SENSOR_STATUS_JSON_NAME] == false ? "checked" : "") + ">"
"                    <label class='form-check-label' for='flameDisabled'>Disabled</label>"
"                </div>"
"                <div class='invalid-feedback'>Please select a status.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='flameDropdown'>Flame state</label>"
"                <select class='form-control' id='flameDropdown' name='flameDropdown'>"
"                    <option value='0'" + (flameSensor[STATUS_JSON_NAME] == 0 ? "selected" : "") + ">PRESENT</option>"
"                    <option value='1'" + (flameSensor[STATUS_JSON_NAME] == 1 ? "selected" : "") + ">ABSENT</option>"
"                </select>"
"                <div class='invalid-feedback'>Please select a choice from the dropdown.</div>"
"            </div>"
"        </div>"
"    </div>"
"    <div class='col'>"
"        <div class='sensor-group'>"
"            <h2>Motion Detection</h2>"
"            <!-- Motion Detection fields -->"
"            <div class='form-group'>"
"                <label>Status</label>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='motionStatus' id='motionEnabled' value='true'"+ (motionSensor[SENSOR_STATUS_JSON_NAME] == true ? "checked" : "") +">"
"                    <label class='form-check-label' for='motionEnabled'>Enabled</label>"
"                </div>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='motionStatus' id='motionDisabled' value='false'"+ (motionSensor[SENSOR_STATUS_JSON_NAME] == false ? "checked" : "") +">"
"                    <label class='form-check-label' for='motionDisabled'>Disabled</label>"
"                </div>"
"                <div class='invalid-feedback'>Please select a status.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='motionDropdown'>Motion state</label>"
"                <select class='form-control' id='motionDropdown' name='motionDropdown'>"
"                    <option value='0'" + (motionSensor[STATUS_JSON_NAME] == 0 ? "selected" : "") + ">DETECTED</option>"
"                    <option value='1'" + (motionSensor[STATUS_JSON_NAME] == 1 ? "selected" : "") + ">STANDBY</option>"
"                    <option value='2'" + (motionSensor[STATUS_JSON_NAME] == 2 ? "selected" : "") + ">INITIALIZE</option>"
"                </select>"
"                <div class='invalid-feedback'>Please select a choice from the dropdown.</div>"
"            </div>"
"        </div>"
"    </div>"
"    <div class='col'>"
"        <div class='sensor-group'>"
"            <h2>Light Sensor</h2>"
"            <!-- Light Sensor fields -->"
"            <div class='form-group'>"
"                <label for='lightSlider'>Low light threshold</label>"
"                <span id='lightSliderValue' class='d-block text-muted mb-2'>Current: " + String(lightSensor[SENSOR_VALUE_JSON_NAME]) +"/" + String(lightSensor[SENSOR_THRESHOLD_JSON_NAME]) +"</span>"
"                <input type='range' class='form-control-range mb-3' id='lightSlider' name='lightSlider' min='0' max='1000' value='"+ String(lightSensor[SENSOR_THRESHOLD_JSON_NAME]) + "'>"
"                <input type='number' class='form-control' id='lightSliderInput' name='lightSliderInput' min='0' max='1000' value='"+ String(lightSensor[SENSOR_THRESHOLD_JSON_NAME]) + "'>"
"                <div class='invalid-feedback'>Please adjust the slider within the range of 0 to 1000.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='lightIntervalSlider'>Light reading interval</label>"
"                <span id='lightIntervalSliderValue' class='d-block text-muted mb-2'>Current: " + String(lightSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "</span>"
"                <input type='range' class='form-control-range mb-3' id='lightIntervalSlider' name='lightIntervalSlider' min='1000' max='60000' step='250' value='"+ String(lightSensor[SENSOR_READING_INTERVAL_JSON_NAME]) +"'>"
"                <input type='number' class='form-control' id='lightIntervalSliderInput' name='lightIntervalSliderInput' min='1000' max='60000' step='250' value='"+ String(lightSensor[SENSOR_READING_INTERVAL_JSON_NAME]) +"'>"
"                <div class='invalid-feedback'>Please adjust the slider within the range of 1000 to 60000.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label>Status</label>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='lightStatus' id='lightEnabled' value='true'"+ (lightSensor[SENSOR_STATUS_JSON_NAME] == true ? "checked" : "") +">"
"                    <label class='form-check-label' for='lightEnabled'>Enabled</label>"
"                </div>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='lightStatus' id='lightDisabled' value='false'"+ (lightSensor[SENSOR_STATUS_JSON_NAME] == false ? "checked" : "") +">"
"                    <label class='form-check-label' for='lightDisabled'>Disabled</label>"
"                </div>"
"                <div class='invalid-feedback'>Please select a status.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='lightDropdown'>State</label>"
"                <select class='form-control' id='lightDropdown' name='lightDropdown'>"
"                    <option value='0'" + (lightSensor[STATUS_JSON_NAME] == 0 ? "selected" : "") + ">NORMAL LIGHT</option>"
"                    <option value='1'" + (lightSensor[STATUS_JSON_NAME] == 1 ? "selected" : "") + ">LOW LIGHT</option>"
"                </select>"
"                <div class='invalid-feedback'>Please select a choice from the dropdown.</div>"
"            </div>"
"        </div>"
"    </div>"
"    <div class='col'>"
"        <div class='sensor-group'>"
"            <h2>RGB LED</h2>"
"            <!-- RGB LED fields -->"
"            <div class='form-group'>"
"                <label>Status</label>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='rgbStatus' id='rgbEnabled' value='true'"+ (rgb[SENSOR_STATUS_JSON_NAME] == true ? "checked" : "") +">"
"                    <label class='form-check-label' for='rgbEnabled'>Enabled</label>"
"                </div>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='rgbStatus' id='rgbDisabled' value='false'"+ (rgb[SENSOR_STATUS_JSON_NAME] == false ? "checked" : "") +">"
"                    <label class='form-check-label' for='rgbDisabled'>Disabled</label>"
"                </div>"
"                <div class='invalid-feedback'>Please select a status.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='rgbDropdown'>RGB State</label>"
"                <select class='form-control' id='rgbDropdown' name='rgbDropdown'>"
"                   <option value='0'" +  (rgb[STATUS_JSON_NAME] == 0 ? "selected" : "") + ">AUTO</option>"
"                    <option value='3'" + (rgb[STATUS_JSON_NAME] == 3 ? "selected" : "") + ">MANUAL ON</option>"
"                    <option value='4'" + (rgb[STATUS_JSON_NAME] == 4 ? "selected" : "") + ">MANUAL OFF</option>"
"                </select>"
"                <div class='invalid-feedback'>Please select a choice from the dropdown.</div>"
"            </div>"
"        </div>"
"    </div>"
"    <div class='col'>"
"        <div class='sensor-group'>"
"            <h2>ALARM</h2>"
"            <!-- ALARM fields -->"
"            <div class='form-group'>"
"                <label>The alarm is: </label>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='alarmStatus' id='alarmEnabled' value='true'"+ (alarm[SENSOR_STATUS_JSON_NAME] == true ? "checked" : "") +">"
"                    <label class='form-check-label' for='alarmEnabled'>Enabled</label>"
"                </div>"
"                <div class='form-check'>"
"                    <input class='form-check-input' type='radio' name='alarmStatus' id='alarmDisabled' value='false'"+ (alarm[SENSOR_STATUS_JSON_NAME] == false ? "checked" : "") +">"
"                    <label class='form-check-label' for='alarmDisabled'>Disabled</label>"
"                </div>"
"                <div class='invalid-feedback'>Please select a status.</div>"
"            </div>"
"            <div class='form-group'>"
"                <label for='alarmDropdown'>State</label>"
"                <select class='form-control' id='alarmDropdown' name='alarmDropdown'>"
"                    <option value='true'" + (alarm[STATUS_JSON_NAME] == true ? "selected" : "") + ">ACTIVE</option>"
"                    <option value='false'" + (alarm[STATUS_JSON_NAME] == false ? "selected" : "") + ">STANDBY</option>"
"                </select>"
"                <div class='invalid-feedback'>Please select a choice from the dropdown.</div>"
"            </div>"
"        </div>"
"    </div>"
"</div>"
"<div class='row'>"
"<button type='submit' class='btn btn-primary btn-block'>Submit</button>"
"</div>"
"</form>"
"</div>"
"<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js'></script>"
"<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js' integrity='sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p' crossorigin='anonymous'></script>"
"<script>"
"    $(document).ready(function() {"
"        $('#lightSlider, #lightSliderInput').on('input', function() {"
"            var value = this.value;"
"            $('#' + this.id + 'Value').html('Current: " + String(lightSensor[SENSOR_VALUE_JSON_NAME]) + "/' + value);"
"            $('#' + this.id).val(value);"
"            $('#' + this.id + 'Input').val(value);"
"        });"
"        $('#lightIntervalSlider, #lightIntervalSliderInput').on('input', function() {"
"            var value = this.value;"
"            $('#' + this.id + 'Value').html('Current: " + String(lightSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "');"
"            $('#' + this.id).val(value);"
"            $('#' + this.id + 'Input').val(value);"
"        });"
"        $('#flameIntervalSlider, #flameIntervalSliderInput').on('input', function() {"
"            var value = this.value;"
"            $('#' + this.id + 'Value').html('Current: " + String(flameSensor[SENSOR_READING_INTERVAL_JSON_NAME]) + "');"
"            $('#' + this.id).val(value);"
"            $('#' + this.id + 'Input').val(value);"
"        });"
"        $('#myForm').on('submit', function(e) {"
"            e.preventDefault();"
"            var sliderValues = ['lightSliderInput' ];"
"            sliderValues.forEach(function(sliderValue) {"
"                var value = $('#' + sliderValue).val();"
"                if (value < 0 || value > 1000) {"
"                    $('#' + sliderValue).addClass('is-invalid');"
"                } else {"
"                    $('#' + sliderValue).removeClass('is-invalid');"
"                }"
"            });"
"            var radioValues = ['flameStatus', 'motionStatus', 'lightStatus', 'rgbStatus','alarmStatus'];"
""
"            radioValues.forEach(function(radioValue) {"
"                if (!$('input[name=\"' + radioValue +'\"]:checked').val()) {"
"                    $('input[name=\"' + radioValue +'\"]').addClass('is-invalid');"
"                } else {"
"                    $('input[name=\"' + radioValue +'\"]').removeClass('is-invalid');"
"                }"
"            });"
""            
"            var dropdDownValues = ['flameDropdown', 'motionDropdown', 'lightDropdown', 'rgbDropdown','alarmDropdown'];"
""            
"            dropdDownValues.forEach(function(dropdown){"
"                if ($('#' + dropdown).val() == '') {"
"                    $('#' + dropdown).addClass('is-invalid');"
"                } else {"
"                    $('#' + dropdown).removeClass('is-invalid');"
"                }"
"            });"
"            if(!$('.is-invalid').length) {"
"                "
"                $.ajax({"
"    url: window.location.toString(),"
"    dataType: 'html',"
"    type: 'post',"
"    contentType: 'application/x-www-form-urlencoded',"
"    data: $('#myForm').serialize() ,"
"    processData: false,"
"    success: function( data, textStatus, jQxhr ){"
"        alert('The new configuration has been sent to the device.');"
"    },"
"    error: function( jqXhr, textStatus, errorThrown ){"
"        alert('Error: ' + textStatus + '. ' + errorThrown );"
"    }"
"});"
"                            }"
"                        });"
"                    });"
"                </script>"
"                </body>"
"                </html>";
return page;
}