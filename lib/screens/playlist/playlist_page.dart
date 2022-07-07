// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:meditation/models/audio.dart';
// import 'package:meditation/models/playlist.dart';
// import 'package:meditation/repositories/content/content_repository.dart';
// import 'package:meditation/repositories/content/content_repository_firebase.dart';
// import 'package:meditation/repositories/player/player_manager.dart';
// import 'package:meditation/util/player/player_navigation_util.dart';
// import 'package:meditation/resources/images.dart';
// import 'package:meditation/screens/player/audio_player_screen.dart';
// import 'package:meditation/util/color.dart';
// import 'package:meditation/widgets/loading_widget.dart';
// import 'package:provider/provider.dart';

// class PlaylistPage extends StatefulWidget {
//   PlaylistPage({Key key}) : super(key: key);

//   @override
//   _PlaylistPageState createState() => _PlaylistPageState();
// }

// class _PlaylistPageState extends State<PlaylistPage> {
//   // ContentRepository contentRepository;
//   final PlayerNavigationUtil playerNavigationRepository =
//       PlayerNavigationUtil();
//   final PlayerManager playerManager = PlayerManager();
//   List<AudioPlayer> playersList = [];
//   bool isPlaying = false;
//   String currentUrl = '';
//   int currentAudioIndex = 0;
//   int previousAudioIndex = 0;
//   List<double> durationInSeconds = [];
//   List<double> currentDurationInSeconds = [];
//   Playlist globalCurrentList;

//   String showDuration(Playlist currentList, int index) {
//     return (playersList.length > index
//             ? (playersList[index]?.duration?.inMinutes ?? 0).toString()
//             : '0') +
//         ' min';
//   }

//   Future<void> play(AudioItem item, int index) async {
//     if (playersList.length > index) {
//       currentAudioIndex = index;
//       previousAudioIndex = currentAudioIndex;
//       setState(() {
//         isPlaying = true;
//       });
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => AudioPlayerScreen(
//             item: item,
//             heroTag: item.id ?? item.name,
//             isPlaylist: true,
//           ),
//         ),
//       );
//     } else {
//       return;
//     }
//   }

//   Future<void> pause(int index) async {
//     setState(() {
//       isPlaying = false;
//     });
//   }

//   Future<int> getAudioDuration(Playlist currentList, int index) async {
//     if (playersList.length > currentList.audios.length) {
//       return 0;
//     }
//     final player = AudioPlayer();
//     final duration =
//         await player.setUrl(currentList.audios[index].getFileUrl());
//     playersList.insert(index, player);
//     if (playersList.length > index) {
//       playersList[index].positionStream.listen((event) {
//         currentDurationInSeconds[index] =
//             double.parse(event.inSeconds.toString());
//       });
//     }
//     durationInSeconds.add(double.parse(duration.inSeconds.toString()));

//     return 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // contentRepository = Provider.of<ContentRepositoryFirebase>(context);
//     MediaQueryData mediaQuery = MediaQuery.of(context);
//     final playlists = ContentRepositoryFirebase.cachedPlaylists;
//     final currentList = playlists[0];
//     playersList = List.filled(
//       currentList.audios.length,
//       AudioPlayer(),
//       growable: true,
//     );
//     globalCurrentList = currentList;
//     if (currentDurationInSeconds.length < currentList.audios.length) {
//       currentDurationInSeconds = List.filled(currentList.audios.length, 0);
//     }
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(Images.mainBackground),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Container(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: mediaQuery.size.height * 0.45,
//                 child: Stack(
//                   children: [
//                     Opacity(
//                       opacity: 0.7,
//                       child: SizedBox(
//                         height: mediaQuery.size.height * 0.45,
//                         width: double.infinity,
//                         child: Image.network(
//                           currentList.getCoverImageFullPath(),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Container(
//                         child: _buildPlayButton(
//                           currentList.audios[currentAudioIndex],
//                           currentAudioIndex,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(
//                         top: mediaQuery.size.height * 0.17,
//                       ),
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           currentList.name,
//                           style: TextStyle(
//                             fontSize: 24.0,
//                             fontWeight: FontWeight.w500,
//                             color: whiteColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(
//                         top: mediaQuery.size.height * 0.24,
//                       ),
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           currentList.description,
//                           style: TextStyle(
//                             fontSize: 18.0,
//                             fontWeight: FontWeight.w400,
//                             color: whiteColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: mediaQuery.size.width * 0.1,
//                           vertical: mediaQuery.size.height * 0.02,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Color.fromRGBO(225, 225, 225, 0.6),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         padding: EdgeInsets.all(
//                           mediaQuery.size.width * 0.04,
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               currentList.audios.length.toString() +
//                                   ' sessions',
//                               style: TextStyle(
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.w500,
//                                 color: whiteColor,
//                               ),
//                             ),
//                             Spacer(),
//                             StreamBuilder<double>(
//                               stream: playerManager.getDurationProgress(),
//                               initialData: 0,
//                               builder: (BuildContext context,
//                                   AsyncSnapshot<double> snapshot) {
//                                 return Container(
//                                   child: Text(
//                                     getSessionProgress(snapshot.data)
//                                             .toString()
//                                             .replaceAll('.0', '') +
//                                         ' %',
//                                     style: TextStyle(
//                                       fontSize: 14.0,
//                                       fontWeight: FontWeight.w500,
//                                       color: whiteColor.withOpacity(0.5),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             SizedBox(
//                               width: 9,
//                             ),
//                             StreamBuilder<double>(
//                               stream: playerManager.getDurationProgress(),
//                               initialData: 0.0,
//                               builder: (BuildContext context,
//                                   AsyncSnapshot<double> snapshot) {
//                                 return Container(
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         height: 4,
//                                         width: mediaQuery.size.width *
//                                             0.25 *
//                                             getSessionProgress(snapshot.data) /
//                                             100,
//                                         color: whiteColor,
//                                       ),
//                                       Container(
//                                         height: 4,
//                                         width: mediaQuery.size.width * 0.25,
//                                         color: whiteColor.withOpacity(0.5),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: currentList.audios.length,
//                   padding: EdgeInsets.only(
//                     top: 10,
//                     left: mediaQuery.size.width * 0.02,
//                     right: mediaQuery.size.width * 0.02,
//                   ),
//                   itemBuilder: (BuildContext context, int index) {
//                     return FutureBuilder<int>(
//                       future: getAudioDuration(currentList, index),
//                       initialData: 0,
//                       builder:
//                           (BuildContext context, AsyncSnapshot<int> snapshot) {
//                         if (!snapshot.hasData) {
//                           return LoadingWidget();
//                         }
//                         return GestureDetector(
//                           onTap: () {
//                             isPlaying && currentAudioIndex == index
//                                 ? pause(index)
//                                 : play(currentList.audios[index], index);
//                           },
//                           child: Container(
//                             child: ListTile(
//                               tileColor: index == currentAudioIndex
//                                   ? whiteColor.withOpacity(0.5)
//                                   : Colors.transparent,
//                               leading: _buildListPlayButton(
//                                 currentList.audios[index],
//                                 index,
//                               ),
//                               title: Text(
//                                 currentList.audios[index].name,
//                                 style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.w500,
//                                   color: whiteColor,
//                                 ),
//                               ),
//                               trailing: Text(
//                                 showDuration(currentList, index),
//                                 style: TextStyle(
//                                   fontSize: 14.0,
//                                   fontWeight: FontWeight.w500,
//                                   color: whiteColor.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton(AudioItem item, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: IconButton(
//         iconSize: 80.0,
//         icon: SvgPicture.asset(
//           Images.play,
//           color: Colors.white,
//           width: 80.0,
//           height: 80.0,
//         ),
//         onPressed: () => play(item, index),
//         color: Colors.white,
//       ),
//     );
//   }

//   Widget _buildListPlayButton(AudioItem item, int index) {
//     return IconButton(
//       // iconSize: 50.0,
//       icon: Image.asset(
//         Images.playlistPlay,
//         color: Colors.white,
//         width: 50.0,
//         height: 50.0,
//       ),
//       onPressed: () => play(item, index),
//       color: Colors.white,
//     );
//   }

//   double getSessionProgress(double currentDuration) {
//     double allProgress = 0;
//     try {
//       for (var i = 0; i < globalCurrentList.audios.length; i++) {
//         allProgress += durationInSeconds[i];
//       }
//     } catch (e) {
//       return 0;
//     }

//     if (allProgress == 0) return 0;
//     final progress = ((currentDuration / allProgress) * 100).roundToDouble();
//     if (progress > 100) {
//       return 100.0;
//     }
//     return progress;
//   }
// }
