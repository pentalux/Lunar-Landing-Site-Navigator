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
 function saveMission(){saved.setValue('mission',JSON.stringify({index:selectedSite,lat:site.lat,lon:site.lon,date:startUtc,hours:durationHours,height:observerHeight,margin:clearance,watts:panelWatts}));saved.sync();message="Mission saved";}
 function loadMission(){var raw=saved.value('mission','');if(!raw){message="No saved mission";return;}try{var s=JSON.parse(raw);if(s.index<0)setCustom(s.lat,s.lon);else selectedSite=Mission.clamp(s.index,0,7);siteMarked=true;durationHours=Mission.clamp(s.hours,672,2160);observerHeight=Mission.clamp(s.height,0,10);clearance=Mission.clamp(s.margin,0,5);panelWatts=Mission.clamp(s.watts,1,100000);setDate(Mission.dateLabel(s.date));seek(0);message="Mission restored";}catch(e){message="Saved mission could not be read";}}
 function reportText(){return Mission.report(site,startUtc,durationHours,observerHeight,clearance);}
}

