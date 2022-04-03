import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:quran_app/helpers/settings_helpers.dart';
import 'package:quran_app/helpers/shimmer_helpers.dart';
import 'package:quran_app/localizations/app_localizations.dart';
import 'package:quran_app/models/chapters_models.dart';
import 'package:quran_app/models/juz_model.dart';
import 'package:quran_app/screens/quran_aya_screen.dart';
import 'package:quran_app/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:math' as math;

class QuranJuzScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuranJuzScreenState();
  }
}

class _QuranJuzScreenState extends State<QuranJuzScreen> {
  QuranJuzScreenScopedModel quranJuzScreenScopedModel =
      QuranJuzScreenScopedModel();

  @override
  void initState() {
    (() async {
      await quranJuzScreenScopedModel.getJuzs();
      await quranJuzScreenScopedModel.getChapters();
    })();

    super.initState();
  }

  @override
  void dispose() {
    quranJuzScreenScopedModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ScopedModel<QuranJuzScreenScopedModel>(
            model: quranJuzScreenScopedModel,
            child: ScopedModelDescendant<QuranJuzScreenScopedModel>(
              builder: (
                BuildContext context,
                Widget child,
                QuranJuzScreenScopedModel model,
              ) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: model.isGettingJuzs
                      ? 5
                      : (model.juzModel?.juzs?.length ?? 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (model.isGettingJuzs) {
                      return chapterDataCellShimmer();
                    }

                    var chapter = model.juzModel?.juzs?.elementAt(index);
                    return chapterDataCell(chapter);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget chapterDataCell(Juz juz) {
    if (juz == null) {
      return Container();
    }

    int firstSura = int.parse(juz.verseMapping.keys.first);
    int firstAya = int.parse(juz.verseMapping.values.first.split("-")[0]);

    var selectedChapter =
        quranJuzScreenScopedModel.chaptersModel.chapters.firstOrDefault(
      (v) => v.chapterNumber == firstSura && firstAya <= v.versesCount,
    );

    // return InkWell(
    //   onTap: () {
    //     Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (BuildContext context) {
    //           return QuranAyaScreen(
    //             chapter: selectedChapter,
    //           );
    //         },
    //       ),
    //     );
    //   },
    //   child: Container(
    //   padding: EdgeInsets.symmetric(
    //     vertical: 7.5,
    //   ),
    //   child: Row(
    //     children: <Widget>[
    //       SizedBox(
    //         width: 15,
    //       ),
    //       Expanded(
    //         child:
    //       ),
    //
    //     ],
    //   ),
    // ),
    // );
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return QuranAyaScreen(
                chapter: selectedChapter,
              );
            },
          ),
        );
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '${AppLocalizations.of(context).juzText} ${juz.juzNumber}',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text('${selectedChapter?.nameSimple} $firstSura:$firstAya'),
        ],
      ),
      trailing: Container(
        width: 175,
        child: Text(
          juz.aya ?? '',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget chapterDataCellShimmer() {
    return ShimmerHelpers.createShimmer(
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 7.5,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 20,
                      color: Colors.white,
                    ),
                    SizedBox.fromSize(size: Size.fromHeight(5)),
                    Container(
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  height: 24,
                  width: 75,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranJuzScreenScopedModel extends Model {
  QuranDataService _quranDataService = QuranDataService.instance;
  bool isGettingJuzs = true;

  JuzModel juzModel;

  ChaptersModel chaptersModel = ChaptersModel();

  Future getJuzs() async {
    try {
      isGettingJuzs = true;

      juzModel = await _quranDataService.getJuzs();
      notifyListeners();
    } finally {
      isGettingJuzs = false;
      notifyListeners();
    }
  }

  Future getChapters() async {
    var locale = SettingsHelpers.instance.getLocale();
    chaptersModel = await _quranDataService.getChapters(
      locale,
    );
    notifyListeners();
  }

  void dispose() {
    _quranDataService.dispose();
  }
}
