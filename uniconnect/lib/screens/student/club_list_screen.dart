import 'package:flutter/material.dart';
import 'club_detail_screen.dart';
import 'club_ui_models.dart';

class ClubListScreen extends StatefulWidget {
  const ClubListScreen({super.key});

  @override
  State<ClubListScreen> createState() => _ClubListScreenState();
}

class _ClubListScreenState extends State<ClubListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<UiClub> _allClubs = [
    UiClub(
      id: 'tech',
      name: 'Tech Society',
      description: 'For technology enthusiasts',
      category: 'Academic',
      members: 234,
      events: 5,
      icon: Icons.groups,
      color: Color(0xFF1E88E5),
      isAdmin: true,
      isJoined: true,
      announcements: ['Welcome new members!'],
    ),
    UiClub(
      id: 'drama',
      name: 'Drama Club',
      description: 'Theatre and performing arts',
      category: 'Arts',
      members: 156,
      events: 3,
      icon: Icons.theater_comedy,
      color: Color(0xFF8E24AA),
      isAdmin: false,
      isJoined: true,
      announcements: ['Rehearsals start next week'],
    ),
    UiClub(
      id: 'sports',
      name: 'Sports Club',
      description: 'Campus sports and fitness',
      category: 'Sports',
      members: 412,
      events: 7,
      icon: Icons.sports_soccer,
      color: Color(0xFF43A047),
      isAdmin: false,
      isJoined: true,
      announcements: ['Inter-faculty tournament signups open'],
    ),
    UiClub(
      id: 'debate',
      name: 'Debate Society',
      description: 'Public speaking and debates',
      category: 'Academic',
      members: 89,
      events: 2,
      icon: Icons.record_voice_over,
      color: Color(0xFFFB8C00),
      isAdmin: false,
      isJoined: false,
      announcements: ['Welcome new members!'],
    ),
    UiClub(
      id: 'photo',
      name: 'Photography Club',
      description: 'Capture campus moments',
      category: 'Arts',
      members: 178,
      events: 4,
      icon: Icons.camera_alt,
      color: Color(0xFFE53935),
      isAdmin: false,
      isJoined: false,
      announcements: ['Photo walk this Friday'],
    ),
    UiClub(
      id: 'entre',
      name: 'Entrepreneurship Society',
      description: 'For aspiring entrepreneurs',
      category: 'Business',
      members: 201,
      events: 6,
      icon: Icons.lightbulb,
      color: Color(0xFF5E35B1),
      isAdmin: false,
      isJoined: false,
      announcements: ['Pitch night submissions close soon'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && _searchController.text.isNotEmpty) {
        setState(() {
          _searchController.clear();
        });
      }
    });
  }

  List<UiClub> getMyClubs() {
    List<UiClub> result = [];
    for (int i = 0; i < _allClubs.length; i++) {
      if (_allClubs[i].isJoined) {
        result.add(_allClubs[i]);
      }
    }
    return result;
  }

  List<UiClub> getDiscoverClubs() {
    String query = _searchController.text.trim().toLowerCase();
    List<UiClub> notJoined = [];
    for (int i = 0; i < _allClubs.length; i++) {
      if (!_allClubs[i].isJoined) {
        notJoined.add(_allClubs[i]);
      }
    }
    if (query.isEmpty) return notJoined;

    List<UiClub> filtered = [];
    for (int i = 0; i < notJoined.length; i++) {
      if (notJoined[i].name.toLowerCase().contains(query) ||
          notJoined[i].description.toLowerCase().contains(query) ||
          notJoined[i].category.toLowerCase().contains(query)) {
        filtered.add(notJoined[i]);
      }
    }
    return filtered;
  }

  void toggleMembership(String clubId, bool shouldJoin) {
    setState(() {
      for (int i = 0; i < _allClubs.length; i++) {
        if (_allClubs[i].id == clubId) {
          _allClubs[i] = _allClubs[i].copyWith(isJoined: shouldJoin);
          break;
        }
      }
    });
  }

  void openDetails(UiClub club) async {
    var result = await Navigator.of(context).push<ClubActionResult>(
      MaterialPageRoute(
        builder: (context) => ClubDetailScreen(
          club: club,
          onJoin: () => toggleMembership(club.id, true),
          onLeave: () => toggleMembership(club.id, false),
        ),
      ),
    );

    if (!mounted) return;
    if (result == ClubActionResult.join) {
      toggleMembership(club.id, true);
    } else if (result == ClubActionResult.leave) {
      toggleMembership(club.id, false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Clubs',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Tab bar
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black.withAlpha(115),
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'My Clubs'),
                    Tab(text: 'Discover'),
                  ],
                ),
              ),
              SizedBox(height: 14),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [buildMyClubsTab(), buildDiscoverTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMyClubsTab() {
    List<UiClub> clubs = getMyClubs();
    if (clubs.isEmpty) {
      return Center(child: Text('No clubs yet'));
    }
    return buildClubList(clubs, false);
  }

  Widget buildDiscoverTab() {
    List<UiClub> clubs = getDiscoverClubs();
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search clubs...',
            prefixIcon: Icon(Icons.search, color: Colors.black.withAlpha(102)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 12),
        Expanded(child: buildClubList(clubs, true)),
      ],
    );
  }

  Widget buildClubList(List<UiClub> clubs, bool showJoinBtn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          UiClub c = clubs[index];
          return Column(
            children: [
              if (index > 0) Divider(height: 1, indent: 74),
              InkWell(
                onTap: () => openDetails(c),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: c.color.withAlpha(31),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(c.icon, color: c.color),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (c.isAdmin)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE9EEF6),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3A4A66),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              c.description,
                              style: TextStyle(
                                color: Colors.black.withAlpha(140),
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.black.withAlpha(115),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${c.members} members',
                                  style: TextStyle(
                                    color: Colors.black.withAlpha(140),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.event_outlined,
                                  size: 16,
                                  color: Colors.black.withAlpha(115),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${c.events} events',
                                  style: TextStyle(
                                    color: Colors.black.withAlpha(140),
                                  ),
                                ),
                              ],
                            ),
                            if (showJoinBtn) ...[
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () => openDetails(c),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1E88E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Join Club'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.black.withAlpha(77),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
