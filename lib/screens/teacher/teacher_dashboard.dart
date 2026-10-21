import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});
  @override Widget build(BuildContext context) => PageContainer(title:'Good Evening, Professor',subtitle:'Manage teaching, attendance and grading from one place.',child:Column(children:[
    LayoutBuilder(builder:(_,c)=>GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:c.maxWidth>800?4:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:2.1,children:const[_TeacherStat('Classes Today','3',Icons.school_outlined),_TeacherStat('To Grade','18',Icons.grading_outlined),_TeacherStat('Attendance','2',Icons.fact_check_outlined),_TeacherStat('Deadlines','4',Icons.assignment_outlined)])),
    const SizedBox(height:18),
    LayoutBuilder(builder:(_,c)=>c.maxWidth>850?const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:_TeachingToday()),SizedBox(width:14),Expanded(child:_TeacherActions())]):const Column(children:[_TeachingToday(),SizedBox(height:14),_TeacherActions()])),
  ]));
}
class _TeacherStat extends StatelessWidget{final String title,value;final IconData icon;const _TeacherStat(this.title,this.value,this.icon);@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Icon(icon,color:AppTheme.red),const SizedBox(width:12),Expanded(child:Text(title,style:const TextStyle(color:AppTheme.muted))),Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:AppTheme.navy))])));}
class _TeachingToday extends StatelessWidget{const _TeachingToday();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SectionHeader('Today\'s Teaching'),const SizedBox(height:8),for(final x in const [('09:00 AM','Deep Learning','Lab 204'),('11:30 AM','Machine Learning','Room 305'),('02:00 PM','Computer Vision','Lab 101')])Card(child:ListTile(leading:const Icon(Icons.schedule_outlined,color:AppTheme.info),title:Text(x.$2,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${x.$1} • ${x.$3}')))]);}
class _TeacherActions extends StatelessWidget{const _TeacherActions();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SectionHeader('Action Required'),const SizedBox(height:8),const EmptyActionCard(icon:Icons.grading_outlined,title:'Grade submissions',subtitle:'18 student submissions need review.'),SizedBox(height:10),const EmptyActionCard(icon:Icons.fact_check_outlined,title:'Mark attendance',subtitle:'Two classes need attendance today.'),SizedBox(height:10),const EmptyActionCard(icon:Icons.campaign_outlined,title:'Course announcement',subtitle:'Publish an update to your students.')]);}
