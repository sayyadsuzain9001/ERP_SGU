import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});
  @override Widget build(BuildContext context)=>PageContainer(title:'University Administration',subtitle:'Monitor university-wide academic and operational activity.',child:Column(children:[
    LayoutBuilder(builder:(_,c)=>GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:c.maxWidth>850?4:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:2.1,children:const[_AdminStat('Students','4,820',Icons.people_outline),_AdminStat('Teachers','286',Icons.co_present_outlined),_AdminStat('Courses','412',Icons.school_outlined),_AdminStat('Requests','38',Icons.support_agent_outlined)])),
    const SizedBox(height:18),
    LayoutBuilder(builder:(_,c)=>c.maxWidth>850?const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:_AdminActivity()),SizedBox(width:14),Expanded(child:_AdminActions())]):const Column(children:[_AdminActivity(),SizedBox(height:14),_AdminActions()])),
  ]));
}
class _AdminStat extends StatelessWidget{final String title,value;final IconData icon;const _AdminStat(this.title,this.value,this.icon);@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Icon(icon,color:AppTheme.red),const SizedBox(width:12),Expanded(child:Text(title,style:const TextStyle(color:AppTheme.muted))),Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800,color:AppTheme.navy))])));}
class _AdminActivity extends StatelessWidget{const _AdminActivity();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SectionHeader('University Activity'),const SizedBox(height:8),const Card(child:Column(children:[ListTile(leading:Icon(Icons.person_add_outlined,color:AppTheme.info),title:Text('126 new student records'),subtitle:Text('Admissions • today')),ListTile(leading:Icon(Icons.assignment_outlined,color:AppTheme.warning),title:Text('84 assignments published'),subtitle:Text('Academic system • today')),ListTile(leading:Icon(Icons.payments_outlined,color:AppTheme.success),title:Text('RM 48,500 payments received'),subtitle:Text('Finance • today'))]))]);}
class _AdminActions extends StatelessWidget{const _AdminActions();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SectionHeader('Action Required'),const SizedBox(height:8),const EmptyActionCard(icon:Icons.approval_outlined,title:'Pending requests',subtitle:'38 service requests require processing.'),SizedBox(height:10),const EmptyActionCard(icon:Icons.history_outlined,title:'Audit review',subtitle:'12 recent administrative changes.')]);}
