import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicplayer2/functions/addTofavorite.dart';
import 'package:musicplayer2/colors/colors.dart';
import 'package:musicplayer2/models/favourites.dart';
import 'package:musicplayer2/screens/slider.dart';

import 'package:on_audio_query/on_audio_query.dart';

class LikedSongsList extends StatefulWidget {
  const LikedSongsList({super.key});

  @override
  State<LikedSongsList> createState() => _LikedSongsListState();
}

final audioPlayer = AssetsAudioPlayer.withId('0');

class _LikedSongsListState extends State<LikedSongsList> {
  final List<favourites> favourite = [];
  final box = favouritesbox.getInstance();
  late List<favourites> favouritesongs2 = box.values.toList();
  bool isalready = true;
  List<Audio> favsong = [];

  @override
  void initState() {
    // TODO: implement initState
    final List<favourites> favouritesongs =
        box.values.toList().reversed.toList();
    for (var item in favouritesongs) {
      favsong.add(
        Audio.file(
          item.songurl.toString(),
          metas: Metas(
            title: item.songname,
            id: item.id.toString(),
          ),
        ),
      );
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   
    return Container(
      color: colordark,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colordark,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                       padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent.shade400,
                            borderRadius: BorderRadius.circular(30)),
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.arrow_back_ios,
                            ),
                          ),
                          color: iconcolor,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text(
                    'Liked Songs',
                    style: GoogleFonts.kanit(fontSize: 20, color: fontcolor),
                  ),
                  subtitle: Text(
                    '${favouritesongs2.length} Songs',
                    style: GoogleFonts.kanit(
                        fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.indigoAccent.shade400),
                        child: IconButton(
                          onPressed: () {
                            audioPlayer.open(
                                Playlist(audios: favsong, startIndex: 0),
                                showNotification: true,
                                headPhoneStrategy:
                                    HeadPhoneStrategy.pauseOnUnplug,
                                loopMode: LoopMode.playlist);
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            color: colordark,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon(Icons.play_arrow)

                ValueListenableBuilder<Box<favourites>>(
                  valueListenable: box.listenable(),
                  builder: (context, Box<favourites> favouriteDB, child) {
                    List<favourites> favouritesongs =
                        favouriteDB.values.toList().reversed.toList();
                    return favouritesongs.isNotEmpty
                        ? (ListView.builder(
                            // reverse: true,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: favouritesongs.length,
                            itemBuilder: ((context, index) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 5),
                                  child: ListTile(
                                      onTap: () {
                                        audioPlayer.open(
                                            Playlist(
                                                audios: favsong,
                                                startIndex: index),
                                            showNotification: true,
                                            headPhoneStrategy:
                                                HeadPhoneStrategy.pauseOnUnplug,
                                            loopMode: LoopMode.playlist);
                                        print(index);
                                      },
                                      leading: QueryArtworkWidget(
                                        keepOldArtwork: true,
                                        artworkBorder:
                                            BorderRadius.circular(10),
                                        id: favouritesongs[index].id!,
                                        type: ArtworkType.AUDIO,
                                      ),
                                      title: Text(
                                        favouritesongs[index].songname!,
                                        style:
                                            GoogleFonts.kanit(color: fontcolor),
                                      ),
                                      trailing: IconButton(
                                          onPressed: () {
                                            deletefavourite(index);
                                          },
                                          icon: const Icon(Icons.favorite),
                                          color: Colors.white)),
                                )),
                          ))
                        : Center(
                            child: Text(
                              "You haven't Liked any songs!",
                              style: GoogleFonts.kanit(color: fontcolor),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
          bottomSheet: const NowSlider(),
        ),
      ),
    );
  }

  showOptions(BuildContext context, int index) {
    double vwidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            //backgroundColor: colorextralight,
            alignment: Alignment.bottomCenter,
            content: Container(
              height: 250,
              width: vwidth,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                        onPressed: () {
                          deletefavourite(index);
                          setState(
                            () {
                              isalready = !isalready;
                            },
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: iconcolor,
                        ),
                        label: Text(
                          'Remove from Favourites',
                          style:
                              GoogleFonts.kanit(color: iconcolor, fontSize: 17),
                        )),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.playlist_add,
                          color: iconcolor,
                        ),
                        label: Text(
                          'Add to Playlist',
                          style:
                              GoogleFonts.kanit(color: fontcolor, fontSize: 17),
                        )),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share,
                          color: iconcolor,
                        ),
                        label: Text(
                          'Share',
                          style:
                              GoogleFonts.kanit(color: fontcolor, fontSize: 17),
                        )),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.shuffle,
                          color: iconcolor,
                        ),
                        label: Text(
                          'Shuffle',
                          style:
                              GoogleFonts.kanit(color: fontcolor, fontSize: 17),
                        )),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.repeat,
                        color: iconcolor,
                      ),
                      label: Text(
                        'Repeat',
                        style:
                            GoogleFonts.kanit(color: fontcolor, fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
