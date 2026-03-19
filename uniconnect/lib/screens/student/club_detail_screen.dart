import 'package:flutter/material.dart';
import 'club_ui_models.dart';

class ClubDetailScreen extends StatelessWidget {
  final UiClub club;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close_rounded),
        ),
        title: Text(club.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // club description
            Text(
              club.description,
              style: TextStyle(
                color: Colors.black.withAlpha(140),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 14),

            // members count + category
            Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 18,
                  color: Colors.black.withAlpha(140),
                ),
                SizedBox(width: 6),
                Text(
                  '${club.members} members',
                  style: TextStyle(
                    color: Colors.black.withAlpha(166),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 14),
                // category pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    club.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),

            SizedBox(height: 18),
            Text(
              'Recent Announcements',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 10),

            // show announcements or empty msg
            if (club.announcements.isEmpty)
              Text(
                'No announcements yet.',
                style: TextStyle(color: Colors.black.withAlpha(128)),
              )
            else
              for (var a in club.announcements)
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(14),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a, style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text(
                        '2 days ago',
                        style: TextStyle(color: Colors.black.withAlpha(115)),
                      ),
                    ],
                  ),
                ),

            SizedBox(height: 24),

            // join / leave button
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () {
                  if (club.isJoined) {
                    onLeave();
                    Navigator.of(context).pop(ClubActionResult.leave);
                  } else {
                    onJoin();
                    Navigator.of(context).pop(ClubActionResult.join);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: club.isJoined
                      ? Color(0xFFFF3B30)
                      : Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  club.isJoined ? 'Leave Club' : 'Join Club',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
