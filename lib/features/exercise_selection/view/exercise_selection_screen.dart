import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/exercise_model.dart';
import '../viewmodel/exercise_viewmodel.dart';
import '../../../core/constants/app_colors.dart';

class ExerciseSelectionScreen extends StatefulWidget {
 const ExerciseSelectionScreen({super.key});

 @override
 State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 late ExerciseViewModel _viewModel;
 bool _showClearButton = false;

 @override
 void initState() {
   super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
     _viewModel = Provider.of<ExerciseViewModel>(context, listen: false);
     if (_viewModel.exercises.isEmpty && !_viewModel.isLoading) {
       _viewModel.fetchInitialExercises();
     }
     _scrollController.addListener(_scrollListener);
     _searchController.addListener(_searchListener);
   });
 }

 void _scrollListener() {
   if (_scrollController.position.pixels >=
           _scrollController.position.maxScrollExtent - 200 &&
       !_viewModel.isLoading &&
       !_viewModel.isFetchingMore) {
     _viewModel.fetchMoreExercises();
   }
 }

 void _searchListener() {
   _viewModel.onSearchChanged(_searchController.text);
   if (mounted) {
     setState(() {
       _showClearButton = _searchController.text.isNotEmpty;
     });
   }
 }

 @override
 void dispose() {
   _scrollController.removeListener(_scrollListener);
   _searchController.removeListener(_searchListener);
   _scrollController.dispose();
   _searchController.dispose();
   
   
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   
   final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;
   final iconColorOnPrimary = Theme.of(context).appBarTheme.foregroundColor ?? (ThemeData.estimateBrightnessForColor(appBarColor) == Brightness.dark ? Colors.white : Colors.black);
   final hintColor = iconColorOnPrimary.withOpacity(0.7);

   return Scaffold(
     appBar: PreferredSize( 
       preferredSize: const Size.fromHeight(60), 
       child: AppBar(
         backgroundColor: AppColors.background, 
         leading: IconButton( 
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary), 
            onPressed: () => Navigator.of(context).pop(),
         ),
         title: Padding(
           padding: const EdgeInsets.symmetric(vertical: 8.0), 
           child: Container(
             height: 40,
             decoration: BoxDecoration(
               color: AppColors.surface, 
               borderRadius: BorderRadius.circular(20), 
               border: Border.all(color: AppColors.divider.withOpacity(0.5)) 
             ),
             child: TextField(
               controller: _searchController,
               decoration: InputDecoration(
                 prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20), 
                 hintText: 'Search exercises...',
                 border: InputBorder.none,
                 hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 16), 
                 contentPadding: const EdgeInsets.only(left: 0, top: 9, bottom: 9, right: 15), 
                 suffixIcon: _showClearButton
                     ? IconButton(
                         icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20), 
                         onPressed: () { _searchController.clear(); },
                       )
                     : null,
               ),
               style: TextStyle(color: AppColors.textPrimary, fontSize: 16), 
               cursorColor: AppColors.primary, 
             ),
           ),
         ),
       ),
     ),
     body: Selector<ExerciseViewModel, bool>(
       selector: (_, viewModel) => viewModel.isLoading && viewModel.exercises.isEmpty,
       builder: (context, isLoadingInitial, _) {
         if (isLoadingInitial) {
           return const Center(child: CircularProgressIndicator());
         }
         return Selector<ExerciseViewModel, List<ExerciseModel>>(
           selector: (_, viewModel) => viewModel.exercises,
           shouldRebuild: (previous, next) => true,
           builder: (context, exercises, _) {
             final viewModel = context.read<ExerciseViewModel>();
             if (!viewModel.isLoading && exercises.isEmpty) {
               return Center(
                 child: Text(
                   viewModel.searchQuery.isEmpty
                       ? 'No exercises found.'
                       : 'No results for "${viewModel.searchQuery}"',
                   style: TextStyle(
                       fontSize: 16,
                       color: AppColors.textSecondary, 
                   ),
                    textAlign: TextAlign.center,
                 ),
               );
             }
             return ListView.builder(
               controller: _scrollController,
               padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
               itemCount: exercises.length + (viewModel.hasMoreData ? 1 : 0),
               itemBuilder: (context, index) {
                 if (index == exercises.length) {
                   return Selector<ExerciseViewModel, bool>(
                       selector: (_, vm) => vm.isFetchingMore,
                       builder: (context, isFetchingMore, _) {
                          return isFetchingMore
                             ? const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 20.0),
                                 child: Center(child: CircularProgressIndicator()),
                               )
                             : const SizedBox.shrink();
                       });
                 }
                 final exercise = exercises[index];
                 return Card(
                   margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                   clipBehavior: Clip.antiAlias,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
                   child: InkWell(
                     onTap: () {
                       Navigator.of(context).pop(exercise);
                     },
                     child: Row(
                       children: [
                         SizedBox(
                           width: 120, 
                           height: 100, 
                           child: ClipRRect(
                             borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomLeft: Radius.circular(12.0),
                             ),
                             child: Image.network(
                               exercise.imageUrl,
                               fit: BoxFit.cover,
                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                 if (loadingProgress == null) {
                                   
                                   return child;
                                 } else {
                                   
                                   return Center(
                                     child: CircularProgressIndicator(
                                       strokeWidth: 2.0, 
                                       
                                       value: loadingProgress.expectedTotalBytes != null
                                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                           : null, 
                                     ),
                                   );
                                 }
                               },
                               errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                 
                                 return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                                 );
                               },
                             ),
                           ),
                         ),
                         Expanded(
                           child: Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Text(
                                   exercise.name,
                                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onPrimary), 
                                   maxLines: 2,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                                 const SizedBox(height: 2), 
                                 Text(
                                   '${exercise.target ?? ''} | ${exercise.equipment ?? ''}'.replaceAll(' | N/A', '').replaceAll('N/A | ', ''),
                                   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 15), 
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                 );
               },
             );
           },
         );
       },
     ),
   );
 }
}

