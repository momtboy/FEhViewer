import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/tab/view/gallery_base.dart';
import 'package:FEhViewer/pages/tab/view/tab_base.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class PopularListTab extends StatefulWidget {
  const PopularListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final tabIndex;
  final scrollController;

  @override
  State<StatefulWidget> createState() => _PopularListTabState();
}

class _PopularListTabState extends State<PopularListTab> {
  Future<List<GalleryItem>> _futureBuilderFuture;
  Widget _lastListWidget;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _loadData();
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      _reloadData();
    });
  }

  Future<List<GalleryItem>> _loadData({bool refresh = false}) async {
    // Global.logger.v('_loadData ');
    final Future<Tuple2<List<GalleryItem>, int>> tuple =
        Api.getPopular(refresh: refresh);
    final Future<List<GalleryItem>> gallerItemBeans =
        tuple.then((Tuple2<List<GalleryItem>, int> value) => value.item1);
    return gallerItemBeans;
  }

  Future<void> _reloadData() async {
    final List<GalleryItem> gallerItemBeans = await _loadData(refresh: true);
    setState(() {
      _futureBuilderFuture = Future<List<GalleryItem>>.value(gallerItemBeans);
    });
  }

  Future<void> _reLoadDataFirst() async {
    setState(() {
      _futureBuilderFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String _title = 'tab_popular'.tr;
    final CustomScrollView customScrollView = CustomScrollView(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await _reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }

  Widget _getGalleryList() {
    return FutureBuilder<List<GalleryItem>>(
      future: _futureBuilderFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<GalleryItem>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _lastListWidget ??
                SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: const CupertinoActivityIndicator(
                      radius: 14.0,
                    ),
                  ),
                );
          case ConnectionState.done:
            if (snapshot.hasError) {
              Global.logger.e('${snapshot.error}');
              return SliverFillRemaining(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: GalleryErrorPage(
                    onTap: _reLoadDataFirst,
                  ),
                ),
              );
            } else {
              _lastListWidget = getGalleryList(snapshot.data, widget.tabIndex);
              return _lastListWidget;
            }
        }
        return null;
      },
    );
  }
}