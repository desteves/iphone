# My iPhone Sensor Data App

A minimal Flask service that receives JSON payloads and stores them directly in MongoDB.

## Prereqs

- Running Docker daemon
- Atlas CLI
- `mongosh`
- Python 3 + pip

## Run

### Set MongoDB

```bash
source .env
make local-up
make local-connect
# Once inside the MongoShell run:
#> use iot
#> db.createCollection("iphone")
#> exit
make vector-index

# Optional to check the vector search index was in fact created:
# make local-connect
# Once inside the MongoShell run:
#> use iot
#> db.iphone.getSearchIndexes()
# [
#   {
#     id: '6952ea4b27b9674f4515fd43',
#     name: 'vector_index',
#     type: 'vectorSearch',
#     status: 'READY',
#     queryable: true,
#     latestVersion: 0,
#     latestDefinition: {
#       fields: [
#         {
#           type: 'vector',
#           path: 'embedding',
#           numDimensions: 512,
#           similarity: 'cosine'
#         },
#         { type: 'filter', path: 'loggingTime' }
#       ]
#     }
#   }
# ]
#> exit



python3 -m venv .venv && source .venv/bin/activate`
pip install -r requirements.txt`
```

### Run the App

```bash
python app.py
# * Serving Flask app 'app'
# // other messages
# * Running on http://192.168.1.155:3333
#Press CTRL+C to quit
# 192.168.1.133 - - [29/Dec/2025 13:13:07] "POST /mdb HTTP/1.1" 200 -
# 192.168.1.133 - - [29/Dec/2025 13:13:07] "POST /mdb HTTP/1.1" 200 -
```

### (Optional) Check data collected via mongosh

```bash
make local-connect
> use iot
> db.iphone.findOne()
```

Sample documents with the values replaced with dummies:

```json
{
  _id: ObjectId('6952d2c327990c357155f356'),
  accelerometerAccelerationX: '111.222',
  accelerometerAccelerationY: '-111.222',
  accelerometerAccelerationZ: '-111.222',
  accelerometerTimestamp_sinceReboot: '111.222',
  altimeterPressure: '111.222',
  altimeterRelativeAltitude: '111.222',
  altimeterReset: '0',
  altimeterTimestamp_sinceReboot: '111.222',
  deviceID: 'diana🍎☎️',
  gyroRotationX: '111.222',
  gyroRotationY: '-111.222',
  gyroRotationZ: '-111.222',
  gyroTimestamp_sinceReboot: '111.222',
  locationAltitude: '111.222',
  locationCourse: '111.222',
  locationCourseAccuracy: '111.222',
  locationFloor: '-111.222',
  locationHeadingAccuracy: '111.222',
  locationHeadingTimestamp_since1970: '111.222',
  locationHeadingX: '0',   // removed for display
  locationHeadingY: '0',   // removed for display
  locationHeadingZ: '-111.222', // removed for display
  locationHorizontalAccuracy: '111.222',
  locationLatitude: '0',
  locationLongitude: '-111.222',
  locationMagneticHeading: '111.222',
  locationSpeed: '0',
  locationSpeedAccuracy: '111.222',
  locationTimestamp_since1970: '111.222',
  locationTrueHeading: '0',
  locationVerticalAccuracy: '0',
  loggingTime: '2025-12-29T13:13:06.981-06:00',
  magnetometerTimestamp_sinceReboot: '111.222',
  magnetometerX: '-111.222',
  magnetometerY: '-111.222',
  magnetometerZ: '-111.222',
  motionAttitudeReferenceFrame: 'XArbitraryCorrectedZVertical',
  motionGravityX: '111.222',
  motionGravityY: '-111.222',
  motionGravityZ: '-111.222',
  motionHeading: '-111.222',
  motionMagneticFieldCalibrationAccuracy: '111.222',
  motionMagneticFieldX: '111.222',
  motionMagneticFieldY: '111.222',
  motionMagneticFieldZ: '-111.222',
  motionPitch: '111.222',
  motionQuaternionW: '-111.222',
  motionQuaternionX: '-111.222',
  motionQuaternionY: '-111.222',
  motionQuaternionZ: '111.222',
  motionRoll: '111.222',
  motionRotationRateX: '111.222',
  motionRotationRateY: '-111.222',
  motionRotationRateZ: '-111.222',
  motionTimestamp_sinceReboot: '111.222',
  motionUserAccelerationX: '-111.222',
  motionUserAccelerationY: '-111.222',
  motionUserAccelerationZ: '-111.222',
  motionYaw: '-111.222'
}
```