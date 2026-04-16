import '../models/service.dart';
import '../models/provider_model.dart';
import '../models/group.dart';

class MockData {
  static final services = <Service>[
    Service(
      id: 's1',
      title: 'Bus Driver',
      iconUrl: 'https://img.icons8.com/color/96/bus.png',
    ),
    Service(
      id: 's2',
      title: 'Car Driver',
      iconUrl: 'https://img.icons8.com/color/96/car.png',
    ),
    Service(
      id: 's3',
      title: 'Towing Service',
      iconUrl: 'https://img.icons8.com/color/96/tow-truck.png',
    ),
    Service(
      id: 's4',
      title: 'Washing Centre',
      iconUrl: 'https://img.icons8.com/color/96/washing-machine.png',
    ),
    Service(
      id: 's5',
      title: 'Truck Driver',
      iconUrl: 'https://img.icons8.com/color/96/truck.png',
    ),
    Service(
      id: 's6',
      title: 'Garage',
      iconUrl: 'https://img.icons8.com/color/96/mechanic.png',
    ),
  ];

  static final providers = <ProviderModel>[
    ProviderModel(
      id: 'p1',
      name: 'Ravi Sharma',
      profession: 'Mechanic',
      location: 'Pune, Chinchwad',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      online: true,
      phone: '+919876543210',
    ),
    ProviderModel(
      id: 'p2',
      name: 'Sunil Deshpande',
      profession: 'Towing Expert',
      location: 'Pune, Hinjewadi',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
      online: false,
      phone: '+919812345678',
    ),
  ];

  static final groups = <GroupModel>[
    GroupModel(id: 'g1', name: 'Chinchwad', membersCount: 1, online: true),
    GroupModel(id: 'g2', name: 'Group 1', membersCount: 1, online: false),
  ];
}
