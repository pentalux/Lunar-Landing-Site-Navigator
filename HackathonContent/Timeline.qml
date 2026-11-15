import QtQuick
import "Mission.js" as Mission

Item {
    id: root
    property var assessment
    property real cursorHour: 0
    property int durationHours: 336
    property double startUtc: Mission.epoch
    signal seek(real hour)
    Canvas {
        id: canvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var c=getContext('2d');c.reset();if(!root.assessment)return;
            var left=130,right=22,top=24,w=width-left-right,laneHeight=Math.max(22,Math.min(30,(height-top-4)/3)),rows=root.assessment.rows,n=rows.length;
            c.font='10px Consolas';
            for(var d=0;d<=root.durationHours;d+=24){var x=left+d/root.durationHours*w;c.strokeStyle='#d5dade';c.beginPath();c.moveTo(x,top-8);c.lineTo(x,top+laneHeight*3);c.stroke();if(d%Math.max(48,Math.ceil(root.durationHours/240)*24)===0){c.fillStyle='#788690';c.fillText(Mission.dateLabel(root.startUtc+d*3600000).slice(5),x-13,14);}}
            var labels=['SUNLIGHT','EARTH LINK','FAVORABLE WINDOW'],colors=['#c8a15d','#6d9caf','#6d9e8e'];
            for(var j=0;j<3;j++){var y=top+j*laneHeight;c.fillStyle='#64737e';c.fillText(labels[j],12,y+12);c.fillStyle='#e3e7e9';c.fillRect(left,y,w,15);for(var i=0;i<n;i++){var s=rows[i],on=j===0?s.sunVisible:j===1?s.earthVisible:s.sunVisible&&s.earthVisible;if(on){c.fillStyle=colors[j];c.fillRect(left+i/n*w,y,w/n+.5,15);}}}
            var cursor=left+root.cursorHour/root.durationHours*w;c.strokeStyle='#246c94';c.lineWidth=1.5;c.beginPath();c.moveTo(cursor,top-9);c.lineTo(cursor,top+laneHeight*3);c.stroke();c.fillStyle='#246c94';c.beginPath();c.moveTo(cursor-4,top-10);c.lineTo(cursor+4,top-10);c.lineTo(cursor,top-4);c.closePath();c.fill();
        }
        MouseArea {
            anchors.fill: parent
            function setHour(x){root.seek(Mission.clamp((x-130)/(width-152),0,1)*root.durationHours);}
            onPressed: mouse => setHour(mouse.x)
            onPositionChanged: mouse => {if(pressed)setHour(mouse.x);}
            cursorShape: Qt.PointingHandCursor
        }
    }
    onAssessmentChanged: canvas.requestPaint()
    onCursorHourChanged: canvas.requestPaint()
    onStartUtcChanged: canvas.requestPaint()
}


