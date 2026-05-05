import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../cv/cv_controller.dart';
import '../cv/cv_detail_view.dart';
// Jika ada detail lamaran untuk job seeker, import di sini. 
// Untuk sementara kita arahkan ke CV Detail jika role company, 
// atau biarkan hanya mark as read jika role job seeker.

class NotificationPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final String role; // "company" atau "job_seeker"

  const NotificationPage({
    super.key,
    required this.currentUser,
    required this.role,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.currentUser['_id'];
      final results = await MongoService.getNotifications(
        receiverId: userId,
        receiverRole: widget.role,
      );
      if (mounted) {
        setState(() {
          _notifications = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleNotificationClick(Map<String, dynamic> notification) async {
    // 1. Mark as read in DB
    final notificationId = MongoService.getMongoId(notification['_id']);
    if (notification['is_read'] == false) {
      await MongoService.markNotificationAsRead(notificationId: notificationId);
      _loadNotifications(); // Refresh list to update UI
    }

    // 2. Navigation logic
    if (!mounted) return;

    if (widget.role == 'company' && notification['type'] == 'new_application') {
      // Go to applicant detail (needs applicant data)
      // Since we only have application_id, we might need to fetch applicant details first.
      _navigateToApplicantDetail(notification['application_id']);
    } else {
      // For job seekers, maybe go to application status page?
      // For now, just showing snackbar that it's read.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi telah dibaca')),
      );
    }
  }

  Future<void> _navigateToApplicantDetail(dynamic applicationId) async {
    // This is a simplified version. Ideally you fetch the application and user data.
    // For now, showing a loader or just fetching enough to open the page.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka detail pelamar...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D1B55);
    const textGrey = Color(0xFF4A5870);
    const lightBlue = Color(0xFFEAF0FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: navy),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] ?? false;
                      final date = (notif['created_at'] as DateTime).toLocal();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _handleNotificationClick(notif),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Container
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: lightBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: navy,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              notif['title'] ?? 'Notifikasi',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: navy,
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif['message'] ?? '',
                                          style: const TextStyle(
                                            color: textGrey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(date),
                                          style: TextStyle(
                                            color: textGrey.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
