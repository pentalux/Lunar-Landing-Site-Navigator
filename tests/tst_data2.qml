import QtQuick
import QtTest
import "../HackathonContent/assets/science/TerrainData.js" as E
TestCase {name:"TerrainData"; function test_values(){compare(E.encodedRows.length,720);verify(isFinite(E.at(1000)));} }
