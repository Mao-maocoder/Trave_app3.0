import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tourist_spot.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/tourist_spot_service.dart';
import '../widgets/platform_image.dart';
import '../theme.dart';
import 'spot_detail_screen.dart';
import '../constants.dart';

class FavoriteSpotsScreen extends StatefulWidget {
  const FavoriteSpotsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteSpotsScreen> createState() => _FavoriteSpotsScreenState();
}

class _FavoriteSpotsScreenState extends State<FavoriteSpotsScreen> {
  final TouristSpotService _spotService = TouristSpotService();
  List<TouristSpot> _favoriteSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final spots = await _spotService.getFavoriteSpots();
    setState(() {
      _favoriteSpots = spots;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '我的收藏' : 'My Favorites', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteSpots.isEmpty
              ? Center(
                  child: Text(
                    isChinese ? '暂无收藏的景点' : 'No favorite spots yet',
                    style: const TextStyle(fontSize: 16, color: kTextSecondary, fontFamily: kFontFamilyTitle),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(kSpaceM),
                  itemCount: _favoriteSpots.length,
                  itemBuilder: (context, index) {
                    final spot = _favoriteSpots[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: kSpaceM),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadiusCard),
                      ),
                      color: kCardBackground,
                      elevation: 0,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(kRadiusS),
                          child: PlatformImage(
                            imageUrl: spot.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(isChinese ? spot.name : spot.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: kFontFamilyTitle)),
                        subtitle: Text(
                          isChinese ? spot.address : spot.addressEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SpotDetailScreen(),
                              settings: RouteSettings(arguments: {
                                'spot': {
                                  'name': spot.name,
                                  'image': spot.imageUrl,
                                  'description': spot.description,
                                  'longitude': spot.longitude,
                                  'latitude': spot.latitude,
                                }
                              }),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 