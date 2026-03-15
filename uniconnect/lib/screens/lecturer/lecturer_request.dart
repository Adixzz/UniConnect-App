import 'package:flutter/material.dart';
import '../../widgets/lecturer_request.dart';
import '../../models/meeting_request.dart'; // Ensure this matches your model filename

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _selectedTabIndex = 0;

  // --- 1. Mutable Mock Data Lists ---
  final List<RequestItem> _pendingRequests = [
    RequestItem(
      name: 'Lisa Anderson',
      initials: 'LA',
      id: 'ST2021001',
      date: '2025-10-29',
      time: '11:00 AM - 11:30 AM',
      description: 'Need help with exam preparation for the upcoming midterm',
      requestedAgo: 'Requested 2 hours ago',
      status: RequestStatus.pending,
    ),
    RequestItem(
      name: 'Tom Martinez',
      initials: 'TM',
      id: 'ST2021002',
      date: '2025-10-30',
      time: '3:00 PM - 3:30 PM',
      description: 'Would like to discuss research opportunities in AI',
      requestedAgo: 'Requested 5 hours ago',
      status: RequestStatus.pending,
    ),
  ];

  final List<RequestItem> _approvedRequests = [
    RequestItem(
      name: 'Sarah Thompson',
      initials: 'ST',
      id: 'ST2021003',
      date: '2025-10-28',
      time: '10:00 AM - 10:30 AM',
      description: 'Assignment clarification',
      requestedAgo: 'Requested 2 days ago',
      status: RequestStatus.approved,
    ),
  ];

  final List<RequestItem> _declinedRequests = [
    RequestItem(
      name: 'James Wilson',
      initials: 'JW',
      id: 'ST2021004',
      date: '2025-10-27',
      time: '4:00 PM - 4:30 PM',
      description: 'Career guidance discussion',
      requestedAgo: 'Requested 3 days ago',
      status: RequestStatus.declined,
    ),
  ];

  // --- 2. Helper getter to switch lists dynamically ---
  List<RequestItem> get _currentRequests {
    if (_selectedTabIndex == 0) return _pendingRequests;
    if (_selectedTabIndex == 1) return _approvedRequests;
    return _declinedRequests;
  }

  // --- 3. Action Functions to Move Items ---
  void _approveRequest(RequestItem request) {
    setState(() {
      _pendingRequests.remove(request);
      // Create a copy of the request with the new 'approved' status
      _approvedRequests.add(
        RequestItem(
          name: request.name,
          initials: request.initials,
          id: request.id,
          date: request.date,
          time: request.time,
          description: request.description,
          requestedAgo: request.requestedAgo,
          status: RequestStatus.approved,
        ),
      );
    });
  }

  void _declineRequest(RequestItem request) {
    setState(() {
      _pendingRequests.remove(request);
      // Create a copy of the request with the new 'declined' status
      _declinedRequests.add(
        RequestItem(
          name: request.name,
          initials: request.initials,
          id: request.id,
          date: request.date,
          time: request.time,
          description: request.description,
          requestedAgo: request.requestedAgo,
          status: RequestStatus.declined,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Requests',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Custom Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildTab('Pending (${_pendingRequests.length})', 0),
                  _buildTab('Approved (${_approvedRequests.length})', 1),
                  _buildTab('Declined (${_declinedRequests.length})', 2),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List of Cards
            Expanded(
              child: ListView.builder(
                itemCount: _currentRequests.length,
                itemBuilder: (context, index) {
                  final request = _currentRequests[index];

                  return RequestCard(
                    request: request,
                    // Connect the buttons on the card
                    onApprove: () => _approveRequest(request),
                    onDecline: () => _declineRequest(request),
                    // Connect the tap event to show the Dialog
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return RequestDetailsDialog(
                            request: request,
                            // Connect the buttons inside the dialog
                            onApprove: () => _approveRequest(request),
                            onDecline: () => _declineRequest(request),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
