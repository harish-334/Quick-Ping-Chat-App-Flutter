import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_ping/api/apis.dart';
import 'package:quick_ping/main.dart';
import 'package:quick_ping/models/chat_user.dart';
import 'package:quick_ping/models/message.dart';
import 'package:quick_ping/screens/view_profile_screen.dart';
import 'package:quick_ping/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // For storing all messages
  List<Message> _list = [];
  // For storing filtered messages based on search
  List<Message> _filteredList = [];
  // For handling search text changes
  final _searchController = TextEditingController();

  // For handling message text changes
  final _textController = TextEditingController();

  // To show and hide emoji
  bool _showEmoji = false;
  bool _isSearching = false; // Flag to track if search mode is active
  bool _isSearchActive = false; // Flag to manage search button highlight

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (_, __) {
          if (_showEmoji) {
            setState(() => _showEmoji = false);
            return;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Messages display area
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          final displayMessages =
                              _isSearching ? _filteredList : _list;

                          if (displayMessages.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              itemCount: displayMessages.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: displayMessages[index],
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                _isSearching
                                    ? 'Search messages... 🔎'
                                    : 'Say Hii! 👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                // Chat input area
                _chatInput(),

                // Emoji picker when clicked on emoji button
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 8,
                            backgroundColor:
                                const Color.fromARGB(255, 191, 230, 249),
                            emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                          ),
                          categoryViewConfig: CategoryViewConfig(
                              initCategory: Category.SMILEYS)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: mq.height * 0.03),
            child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                return Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      ),
                    ),

                    // User image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CachedNetworkImage(
                        width: mq.height * .055,
                        height: mq.height * .055,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),

                    // User name and last seen
                    Padding(
                      padding: EdgeInsets.only(left: mq.width * .05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            list.isNotEmpty ? list[0].name : widget.user.name,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            list.isNotEmpty ? list[0].about : widget.user.about,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    // Search button (now placed on the right)
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: _toggleSearch,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSearchActive
                                ? Colors.blueAccent
                                : Colors.transparent,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.search,
                            color:
                                _isSearchActive ? Colors.white : Colors.black54,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Handle search button tap
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _isSearchActive = !_isSearchActive; // Toggle search active state
      if (!_isSearching) {
        _searchController
            .clear(); // Clear search input when exiting search mode
        _filteredList = [];
      }
    });
  }

  // Handle search input change
  void _onSearchChanged(String query) {
    setState(() {
      _filteredList = _list
          .where((message) =>
              message.msg.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .025, vertical: mq.height * .01),
      child: Row(
        children: [
          // Input field & button
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  // Emoji button (conditionally shown)
                  if (!_isSearching)
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 30,
                        color: Colors.blueAccent,
                      ),
                    ),

                  Expanded(
                    child: TextField(
                      controller:
                          _isSearching ? _searchController : _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: InputDecoration(
                        hintText: _isSearching
                            ? "Search messages..."
                            : "Type message...",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                        contentPadding: _isSearching
                            ? EdgeInsets.only(
                                left: 15, // Add padding on left for search
                                right: 10, // Add padding on right for search
                              )
                            : EdgeInsets.zero, // No padding when not searching
                      ),
                      onChanged: _isSearching ? _onSearchChanged : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Send message button (conditionally shown)
          if (!_isSearching)
            MaterialButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    // On first message
                    APIs.sendFirstMessage(widget.user, _textController.text);
                  } else {
                    // Send message
                    APIs.sendMessage(widget.user, _textController.text);
                  }
                  _textController.text = '';
                }
              },
              minWidth: 0,
              shape: CircleBorder(),
              color: Colors.blue,
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
              child: Icon(
                Icons.send_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
