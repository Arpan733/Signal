void main() {
  List<Map<String, dynamic>> circles = [
    {
      'coordinates': {'latitude': 23.115293, 'longitude': 72.58305},
      'address': {
        'circleName': 'Chandkheda',
        'road': 'Ahmedabad-Patan Highway Road',
        'area': 'Chandkheda',
        'city': 'Ahmedabad',
        'pincode': 123456
      },
      '_id': '655dec9418a31aaecd208552',
      'circleId': 400,
      'numberOfSignals': 4,
      'signalIds': [401, 402, 403, 404],
      'updatedAt': '2023-11-22T12:01:42.380Z',
      'createdAt': '2023-11-22T11:57:08.628Z',
      '__v': 5
    },
    {
      'coordinates': {'latitude': 23.109132, 'longitude': 72.584958},
      'address': {
        'circleName': 'Janata Nagar',
        'road': 'Ahmedabad-Patan Highway Road',
        'area': 'Chandkheda',
        'city': 'Ahmedabad',
        'pincode': 123456
      },
      '_id': '655de95018a31aaecd20851f',
      'circleId': 300,
      'numberOfSignals': 3,
      'signalIds': [301, 302, 303],
      'updatedAt': '2023-11-22T11:45:43.372Z',
      'createdAt': '2023-11-22T11:43:12.209Z',
      '__v': 3
    },
  ];

  Map<String, dynamic> circle = {
    'coordinates': {'latitude': 23.109132, 'longitude': 72.584958},
    'address': {
      'circleName': 'Janata Nagar',
      'road': 'Ahmedabad-Patan Highway Road',
      'area': 'Chandkheda',
      'city': 'Ahmedabad',
      'pincode': 123456
    },
    '_id': '655de95018a31aaecd20851f',
    'circleId': 300,
    'numberOfSignals': 3,
    'signalIds': [301, 302, 303],
    'updatedAt': '2023-11-22T11:45:43.372Z',
    'createdAt': '2023-11-22T11:43:12.209Z',
    '__v': 3
  };

  print(circle == circles[1]);
}
