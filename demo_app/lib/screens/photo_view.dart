import 'package:demo_app/screens/custom_widget_builder.dart'
    as custom_widget_builder;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatelessWidget {
  const PhotoViewScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Inline'),
            Tab(text: 'Popup'),
          ],
        ),
        title: const Text('PhotoViewScreen'),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(
                custom_widget_builder.kHtml,
                factoryBuilder: () => _InlinePhotoViewWidgetFactory(),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(
                custom_widget_builder.kHtml,
                factoryBuilder: () => _PopupPhotoViewWidgetFactory(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InlinePhotoViewWidgetFactory extends WidgetFactory {
  @override
  Widget buildImage(BuildTree tree, ImageMetadata data) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: ClipRect(
        child: PhotoView(
          imageProvider: imageProviderFromNetwork(data.sources.first.url),
        ),
      ),
    );
  }

  @override
  void parse(BuildTree tree) {
    if (tree.element.classes.contains('image')) {
      tree.register(BuildOp(defaultStyles: (_) => {'margin': '1em 0'}));
    }

    super.parse(tree);
  }
}

class _PopupPhotoViewWidgetFactory extends WidgetFactory {
  @override
  Widget buildImageWidget(BuildTree tree, ImageSource src) {
    final built = super.buildImageWidget(tree, src);

    if (built is Image) {
      final url = src.url;
      return Builder(
        builder: (context) => GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                body: PhotoView(
                  heroAttributes: PhotoViewHeroAttributes(tag: url),
                  imageProvider: built.image,
                ),
              ),
            ),
          ),
          child: Hero(tag: url, child: built),
        ),
      );
    }

    return built ?? const SizedBox.shrink();
  }

  @override
  void parse(BuildTree tree) {
    if (tree.element.classes.contains('image')) {
      tree.register(BuildOp(defaultStyles: (_) => {'margin': '1em 0'}));
    }

    super.parse(tree);
  }
}
