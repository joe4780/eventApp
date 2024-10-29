import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'events_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int totalViews = 0;

  @override
  void initState() {
    super.initState();
    _loadViewCount();
  }

  // Load total view count from SharedPreferences
  Future<void> _loadViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalViews = prefs.getInt('${widget.event.pic}_total_views') ?? 0;
    });
  }

  // Save and increment view count
  Future<void> _incrementViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = totalViews + 1;
    await prefs.setInt('${widget.event.pic}_total_views', newCount);

    setState(() {
      totalViews = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EVENT DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text(
                      'TITLE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'VIEW COUNTS: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalViews',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildImageContainer(context, widget.event.pic, 0),
                  _buildImageContainer(context, widget.event.pic, 1),
                  _buildImageContainer(context, widget.event.pic, 2),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.event.text,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openImagePreview(BuildContext context, int initialIndex) async {
    // Increment view count when opening preview
    await _incrementViewCount();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
          images: [widget.event.pic, widget.event.pic, widget.event.pic],
          texts: [widget.event.text, widget.event.text, widget.event.text],
          initialIndex: initialIndex,
          onPageChanged: (index) async {
            await _incrementViewCount();
          },
        ),
      ),
    );
  }

  Widget _buildImageContainer(
      BuildContext context, String imagePath, int index) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () => _openImagePreview(context, index),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final List<String> texts;
  final int initialIndex;
  final Function(int)? onPageChanged;

  const ImagePreviewScreen({
    super.key,
    required this.images,
    required this.texts,
    required this.initialIndex,
    this.onPageChanged,
  });

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Image.asset(
                      widget.images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.texts[index],
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
