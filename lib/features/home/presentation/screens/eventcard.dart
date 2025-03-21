import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../events/domain/entities/host_event_entite.dart';
import '../../../../core/constants/constants.dart';

class EventCard extends StatefulWidget {
  final HostEventEntities event;
  final Function()? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
          margin: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image with Gradient Overlay
              _buildBannerSection(isDarkMode),

              // Event Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Type
                    Row(
                      children: [
                        _buildChip(
                            widget.event.category,
                            isDarkMode
                                ? AppPalette.gradient1
                                : AppPalette.gradient1.withOpacity(0.7),
                            true),
                        const SizedBox(width: 8),
                        _buildChip(
                            widget.event.type,
                            isDarkMode
                                ? AppPalette.gradient2
                                : AppPalette.gradient2.withOpacity(0.7),
                            false),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date and Time with better formatting
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      text: _formatDateRange(
                          widget.event.startDateTime, widget.event.endDateTime),
                      iconColor: AppPalette.info,
                    ),
                    const SizedBox(height: 8),

                    // Location with better formatting
                    _buildInfoRow(
                      icon: Icons.location_on,
                      text: _formatAddress(),
                      iconColor: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),

                    // Price and Capacity with enhanced UI
                    _buildPriceAndCapacityRow(isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection(bool isDarkMode) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: _buildBannerImage(),
        ),
        // Enhanced gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),
        // Event title overlay with improved styling
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            widget.event.title,
            style: AppTextStyles.primaryTextTheme(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Status badge with improved styling
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.event.status),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getStatusIcon(widget.event.status),
                const SizedBox(width: 4),
                Text(
                  _formatStatus(widget.event.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndCapacityRow(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Capacity with icon and improved styling
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppPalette.darkCard
                : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.event.participantCapacity} spots',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Price with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: AppPalette.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppPalette.gradient1.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.event.paymentRequired
                    ? Icons.monetization_on
                    : Icons.card_giftcard,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                widget.event.paymentRequired
                    ? 'IDR ${_formatPrice(widget.event.ticketPrice)}'
                    : 'Free',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerImage() {
    if (!_isValidImageUrl(widget.event.bannerImage)) {
      return _buildPlaceholderImage();
    }

    final fullUrl = '$cloudinaryImageUrl/${widget.event.bannerImage}';

    return Hero(
      tag: 'event_image_${widget.event.id}',
      child: Image.network(
        fullUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingImage(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          Logger.error(
              'Error loading image: $error\nURL: $fullUrl', stackTrace);
          return _buildErrorImage();
        },
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    return url.isNotEmpty && url.contains('/');
  }

  Widget _buildPlaceholderImage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      color: isDarkMode ? AppPalette.darkCard : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined,
              size: 50,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No Image Available',
            style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      color: isDarkMode ? AppPalette.darkCard : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 50, color: isDarkMode ? Colors.red[300] : Colors.red[200]),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage(ImageChunkEvent loadingProgress) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      color: isDarkMode ? AppPalette.darkCard : Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? AppPalette.gradient2 : AppPalette.gradient1),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color, bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFirst)
            Icon(Icons.category, size: 14, color: color)
          else
            Icon(Icons.event, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDarkMode
                  ? AppPalette.darkTextSecondary
                  : AppPalette.lightTextSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final isSameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    final startFormat = DateFormat('EEE, MMM d, yyyy');
    final endFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    if (isSameDay) {
      return '${startFormat.format(start)} • ${timeFormat.format(start)} - ${timeFormat.format(end)}';
    } else {
      return '${startFormat.format(start)} - ${endFormat.format(end)}';
    }
  }

  String _formatAddress() {
    final List<String> addressParts = [];

    if (widget.event.addressLine1.isNotEmpty) {
      addressParts.add(widget.event.addressLine1);
    }

    if (widget.event.city.isNotEmpty) {
      addressParts.add(widget.event.city);
    }

    return addressParts.isEmpty
        ? 'No location specified'
        : addressParts.join(', ');
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'draft':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Icon(Icons.check_circle_outline,
            size: 14, color: Colors.white);
      case 'cancelled':
        return const Icon(Icons.cancel_outlined, size: 14, color: Colors.white);
      case 'pending':
        return const Icon(Icons.hourglass_empty, size: 14, color: Colors.white);
      case 'draft':
        return const Icon(Icons.edit_outlined, size: 14, color: Colors.white);
      default:
        return const Icon(Icons.help_outline, size: 14, color: Colors.white);
    }
  }

  String _formatStatus(String status) {
    // Capitalize first letter
    if (status.isEmpty) return 'Unknown';
    return status.substring(0, 1).toUpperCase() +
        status.substring(1).toLowerCase();
  }
}
