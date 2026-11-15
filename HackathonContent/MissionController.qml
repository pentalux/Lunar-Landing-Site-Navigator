import QtQuick
import QtCore
import "Mission.js" as Mission
QtObject {
 id: state
 property int selectedSite: 0
 property bool siteMarked: false
 signal siteSelected()
 onSelectedSiteChanged: siteMarked=true
 property var custom: Mission.customSite(0,0)
 readonly property var site: selectedSite<0?custom:Mission.sites[selectedSite]
 property double startUtc: Mission.epoch
 property int durationHours: 672
 property real cursorHour: 0
 property real observerHeight: 2
 property real clearance: 1
 property real panelWatts: 1000
 property bool playing: false
 property string message: "Ready · NASA LOLA / JPL DE421 loaded"
 property url settingsLocation: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation)+"/LunarNavigator/mission-pro.ini"
 readonly property double currentUtc: startUtc+cursorHour*3600000
 readonly property var instant: Mission.sample(site,currentUtc,observerHeight,clearance)
 readonly property var assessment: Mission.evaluate(site,startUtc,durationHours,observerHeight,clearance)
 readonly property var comparisons: Mission.sites.map(function(s){return Mission.evaluate(s,startUtc,durationHours,observerHeight,clearance);})
 readonly property string sunset: Mission.eventTime(site,currentUtc,observerHeight,clearance,'sun')
 readonly property string earthset: Mission.eventTime(site,currentUtc,observerHeight,clearance,'earth')
 property Timer playback: Timer { interval: 80; repeat: true; running: state.playing; onTriggered: {state.seek(state.cursorHour+.25);if(state.cursorHour>=state.durationHours)state.playing=false;} }
 property Settings settings: Settings { id: saved; location: state.settingsLocation; category: "Mission" }
 function selectPreset(index){if(index<0||index>=Mission.sites.length)return;selectedSite=index;siteMarked=true;message="Selected "+site.name;siteSelected();}
 function setCustom(lat,lon){if(!isFinite(lat)||!isFinite(lon)||lat < -90||lat >90||lon < -180||lon >180){message="Latitude must be −90…90; longitude −180…180.";return false;}custom=Mission.customSite(lat,lon);selectedSite=-1;siteMarked=true;message="Custom site set · LOLA "+custom.resolution+" m source";siteSelected();return true;}
 function setDate(text){var t=Mission.parseDate(text);if(!isFinite(t)||t<Date.UTC(2026,0,1)||t+durationHours*3600000>Date.UTC(2028,0,1)){message="Choose a UTC date within 2026–2027 with the complete window in range.";return false;}startUtc=t;return true;}
 function seek(h){cursorHour=Mission.clamp(h,0,durationHours);}
 property var savedMissions: []
 Component.onCompleted: readHistory()
 function readHistory(){
  try {
   var entries=JSON.parse(saved.value('history','[]'));
   if(!Array.isArray(entries))entries=[];
   if(!entries.length){var legacy=saved.value('mission','');if(legacy)entries=[JSON.parse(legacy)];}
   savedMissions=entries.filter(validRecord).slice(0,20);
  } catch(e){savedMissions=[];message="Saved history could not be read";}
 }
 function validRecord(s){return s && isFinite(s.lat)&&Math.abs(s.lat)<=90&&isFinite(s.lon)&&Math.abs(s.lon)<=180&&isFinite(s.date)&&[672,1080,1440,2160].indexOf(s.hours)>=0&&s.date>=Date.UTC(2026,0,1)&&s.date+s.hours*3600000<=Date.UTC(2028,0,1)&&isFinite(s.height)&&s.height>=0&&s.height<=10&&isFinite(s.margin)&&s.margin>=0&&s.margin<=5&&isFinite(s.watts)&&s.watts>=1&&s.watts<=100000;}
 function snapshot(){return {index:selectedSite,name:site.name,lat:site.lat,lon:site.lon,date:startUtc,hours:durationHours,height:observerHeight,margin:clearance,watts:panelWatts};}
 function recordName(s){return s.name || (s.index>=0&&s.index<Mission.sites.length?Mission.sites[s.index].name:"Custom site");}
 function recordDetails(s){return s.lat.toFixed(4)+" N / "+s.lon.toFixed(4)+" E | "+Mission.dateLabel(s.date)+" | "+s.hours/24+" days";}
 function saveMission(){
  var entry=snapshot();
  var entries=savedMissions.filter(function(s){return !(s.lat===entry.lat&&s.lon===entry.lon&&s.date===entry.date&&s.hours===entry.hours&&s.height===entry.height&&s.margin===entry.margin&&s.watts===entry.watts);});
  entry.savedAt=new Date().toISOString();entries.unshift(entry);savedMissions=entries.slice(0,20);
  saved.setValue('history',JSON.stringify(savedMissions));saved.sync();message="Mission saved to history and comparison ("+savedMissions.length+" / 20)";
 }
 function loadMission(index){
  var s=savedMissions[index===undefined?0:index];if(!validRecord(s)){message="Saved mission could not be read";return;}
  playing=false;
  if(s.index>=0&&s.index<Mission.sites.length)selectPreset(s.index);else setCustom(s.lat,s.lon);
  durationHours=s.hours;observerHeight=s.height;clearance=s.margin;panelWatts=s.watts;startUtc=s.date;seek(0);message="Restored "+recordName(s);
 }
 function comparisonRows(){
  var entries=savedMissions.map(function(s){return {saved:true,config:s};});
  Mission.sites.forEach(function(site,index){var s=state.snapshot();s.index=index;s.name=site.name;s.lat=site.lat;s.lon=site.lon;entries.push({saved:false,config:s});});
  return entries.map(function(entry){var s=entry.config;var site=s.index>=0&&s.index<Mission.sites.length?Mission.sites[s.index]:Mission.customSite(s.lat,s.lon);entry.result=Mission.evaluate(site,s.date,s.hours,s.height,s.margin);return entry;});
 }
 function reportText(){return Mission.report(site,startUtc,durationHours,observerHeight,clearance);}
}

