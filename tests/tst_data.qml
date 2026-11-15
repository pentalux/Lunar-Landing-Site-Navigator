import QtQuick
import QtTest
import "../HackathonContent/assets/science/Ephemeris.js" as E
TestCase {name:"Data"; function test_values(){compare(E.rows.length,17521);} }

