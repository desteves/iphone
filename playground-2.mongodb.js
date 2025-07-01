/* global sp */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

// Create a new stream processor.
let pipeline = [
  {
    $source: {
      connectionName: 'kafkacluster_topic_iphone',
      topic: 'topic_iphone'
    }
  },
  {
    $match: {
      "$and": [
        // Ensure all required fields exist
        { "deviceID": "diana🍎☎️" },
        { "motionUserAccelerationX": { "$exists": true } },
        { "motionUserAccelerationY": { "$exists": true } },
        { "motionUserAccelerationZ": { "$exists": true } },
        { "motionRotationRateX": { "$exists": true } },
        { "motionRotationRateY": { "$exists": true } },
        { "motionRotationRateZ": { "$exists": true } },
        { "gyroRotationX": { "$exists": true } },
        { "gyroRotationY": { "$exists": true } },
        { "gyroRotationZ": { "$exists": true } }
      ]
    }
  },
  {
    $addFields: {
      loggingTimeISODate: {
        $toDate: "$loggingTime"
      },
      motionAccelerationSum: {
        $add: [
          { "$abs": { "$toDouble": "$motionUserAccelerationX" } },
          { "$abs": { "$toDouble": "$motionUserAccelerationY" } },
          { "$abs": { "$toDouble": "$motionUserAccelerationZ" } }
        ]
      },
      motionRotationRateSum: {
        $add: [
          { "$abs": { "$toDouble": "$motionRotationRateX" } },
          { "$abs": { "$toDouble": "$motionRotationRateY" } },
          { "$abs": { "$toDouble": "$motionRotationRateZ" } }
        ]
      },
      gyroRotationSum: {
        $add: [
          { "$abs": { "$toDouble": "$gyroRotationX" } },
          { "$abs": { "$toDouble": "$gyroRotationY" } },
          { "$abs": { "$toDouble": "$gyroRotationZ" } }
        ]
      }
    }
  },
  {
    $match: {
      "$or": [
        // Check if motion acceleration exceeds threshold
        { "$expr": { "$gt": ["$motionAccelerationSum", 0.05] } },

        // Check if motion rotation rate exceeds threshold
        { "$expr": { "$gt": ["$motionRotationRateSum", 0.3] } },

        // Check if gyro rotation sum exceeds threshold
        { "$expr": { "$gt": ["$gyroRotationSum", 0.05] } }
      ]
    }
  },
  {
    $merge: {
      into: {
        connectionName: 'iphone_motion_detection',
        db: "presentations",
        coll: "iphoneMotionDetections"
      }
    }
  }
];


// var window = {
//   $tumblingWindow: {
//     interval: {
//       size: 10,
//       unit: "second"
//     },
//     pipeline: [ group]
//   }



sp.createStreamProcessor('iphoneStreamProcessor', pipeline);

// More information on the `createStreamProcessor` command can be found at:
// https://www.mongodb.com/docs/atlas/atlas-sp/manage-stream-processor/#create-a-stream-processor
