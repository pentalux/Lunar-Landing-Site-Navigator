import QtQuick
import "Mission.js" as Mission

Item {
    id: root
    property var site: Mission.sites[0]
    property var sample: Mission.sample(site,Mission.epoch,2,1)
    property bool compact: false
    property real observerHeight: 2
    Canvas {
        id: plot
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var c=getContext('2d');c.reset();
            var l=root.compact?30:55,r=18,t=25,b=30,w=width-l-r,h=height-t-b;
            var min=Math.min(-8,root.sample.sunEl-3,root.sample.earthEl-3),max=Math.max(15,root.sample.sunEl+5,root.sample.earthEl+5);
            for(var ha=0;ha<360;ha+=4)max=Math.max(max,Mission.horizon(root.site,ha,root.observerHeight)+3);
            function px(a){return l+a/360*w;}
            function py(e){return t+(max-e)/(max-min)*h;}
            c.font='10px Consolas';c.lineWidth=1;
            for(var e=Math.ceil(min/10)*10;e<=max;e+=10){c.strokeStyle=e===0?'#82909c':'#d5dade';c.beginPath();c.moveTo(l,py(e));c.lineTo(l+w,py(e));c.stroke();c.fillStyle='#7d8992';c.fillText(e+'°',3,py(e)+4);}
            for(var az=0;az<=360;az+=90){c.strokeStyle='#d5dade';c.beginPath();c.moveTo(px(az),t);c.lineTo(px(az),t+h);c.stroke();c.fillStyle='#7d8992';c.fillText(['N','E','S','W','N'][az/90],px(az)-3,height-10);}
            c.beginPath();c.moveTo(px(0),py(min));for(var a=0;a<=360;a+=2)c.lineTo(px(a),py(Mission.horizon(root.site,a,root.observerHeight)));c.lineTo(px(360),py(min));c.closePath();c.fillStyle='#d5dce0';c.fill();
            c.beginPath();for(a=0;a<=360;a+=2){if(a===0)c.moveTo(px(a),py(Mission.horizon(root.site,a,root.observerHeight)));else c.lineTo(px(a),py(Mission.horizon(root.site,a,root.observerHeight)));}c.strokeStyle='#7a8a92';c.lineWidth=1.4;c.stroke();
            var objects=[{a:root.sample.sunAz,e:root.sample.sunEl,color:'#c48c33',label:'SUN'},{a:root.sample.earthAz,e:root.sample.earthEl,color:'#337c9e',label:'EARTH'}];
            for(var i=0;i<objects.length;i++){var o=objects[i];c.strokeStyle=o.color;c.setLineDash([3,4]);c.beginPath();c.moveTo(px(o.a),py(o.e));c.lineTo(px(o.a),py(min));c.stroke();c.setLineDash([]);c.fillStyle=o.color;c.beginPath();c.arc(px(o.a),py(o.e),root.compact?4:6,0,2*Math.PI);c.fill();if(!root.compact)c.fillText(o.label+' '+o.e.toFixed(1)+'°',Math.min(l+w-90,px(o.a)+12),py(o.e)-10);}
            if(!root.compact){c.fillStyle='#7d8992';c.fillText('ELEVATION / DEG',l,12);c.fillText('AZIMUTH / DEG',width-110,height-10);}
        }
    }
    onObserverHeightChanged: plot.requestPaint()
    onSiteChanged: plot.requestPaint()
    onSampleChanged: plot.requestPaint()
}



