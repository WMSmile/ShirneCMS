<?php
/**
 * Created by IntelliJ IDEA.
 * User: shirn
 * Date: 2016/9/16
 * Time: 16:25
 */

namespace app\admin\controller;


use think\Db;

class PaylogController extends BaseController
{
    public function recharge($key='',$status=0){
        $model=Db::view('__MEMBER_RECHARGE__ mr','*');
        $where=array();
        if($status>0){
            switch ($status){
                case 1:
                    $where['mr.status']=0;
                    $where['mr.remark']='';
                    break;
                case 2:
                    $where['mr.status']=0;
                    $where['mr.remark']=array('NEQ','');
                    break;
                case 3:
                    $where['mr.status']=1;
                    break;
                case 4:
                    $where['mr.status']=2;
                    break;
                default:
                    $status=9;
            }
        }
        if(!empty($key)){
            $where['m.username']=array('LIKE',"%$key%");
        }

        $lists=$model->view('__MEMBER__ m',['username','realname'],'mr.member_id=m.id','LEFT')
            ->view('__PAYTYPE__ p',['type','cardname','bank','cardno'],'mr.paytype_id=p.id','LEFT')
            ->order('mr.id DESC')->paginate(15);

        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        $paytype=getPaytypes();

        $total=Db::name('MemberRecharge')->where(array('status'=>1))->sum('amount');
        $this->assign('total',$total);
        $this->assign('key',$key);
        $this->assign('status',$status);
        $this->assign('paytype',$paytype);
        return $this->fetch();
    }

    /**
     * 充值成功
     * @param string $id
     */
    public function rechargeupdate($id=''){
        $id=intval($id);
        if($id==0)$this->error('参数错误 ');
        $recharge=Db::name('member_recharge')->find($id);
        if(empty($recharge))$this->error('充值单不存在');
        if($recharge['status']!=0)$this->error('充值单已处理过了');

        $recharge=Db::name('member_recharge')->lock(true)->find($id);
        if($recharge['status']!=0)$this->error('充值单已处理过了');
        $data['status']=1;
        Db::name('member_recharge')->where(array('id'=>$recharge['id']))->update($data);

        money_log($recharge['member_id'],$recharge['amount'],'充值','charge');

        user_log($this->mid,'rechargeaudit',1,'审核充值单 '.$id ,'manager');
        $this->success('处理成功！');
    }

    public function rechargecancel($id=''){
        $id=intval($id);
        if($id==0)$this->error('参数错误 ');
        $recharge=Db::name('member_recharge')->find($id);
        if(empty($recharge))$this->error('充值单不存在');
        if($recharge['status']!=1)$this->error('充值单未成功');

        $recharge=Db::name('member_recharge')->lock(true)->find($id);
        if($recharge['status']!=1)$this->error('充值单未成功');
        $data=array();
        $data['status']=0;
        $data['audit_at']=time();
        Db::name('member_recharge')->where(array('id'=>$recharge['id']))->update($data);

        money_log($recharge['member_id'],-$recharge['amount'],'充值撤销','charge');


        //首充赠送撤销
        $suf='';
        $rechargelog=Db::name('member_money_log')
            ->where(array('member_id'=>$recharge['member_id'],'create_time'=>array('GT',$recharge['create_time']),'reson'=>'首充赠送','type'=>'charge'))
            ->find();
        if(!empty($rechargelog)){
            $suf=' 撤销首充 '.showmoney($rechargelog['amount']);
            money_log($recharge['member_id'],-$rechargelog['amount'],'首充赠送撤销','charge');
        }
        user_log($this->mid,'rechargecancel',1,'撤销充值单 '.$id.$suf ,'manager');
        $this->success('处理成功！');
    }

    /**
     * 充值作废
     * @param string $id
     */
    public function rechargedelete($id=''){
        $id=intval($id);
        if($id==0)$this->error('参数错误 ');
        $recharge=Db::name('member_recharge')->find($id);
        if(empty($recharge))$this->error('充值单不存在');
        if($recharge['status']!=0)$this->error('充值单已处理过了');

        $recharge=Db::name('member_recharge')->lock(true)->find($id);
        if($recharge['status']!=0)$this->error('充值单已处理过了');
        $data=array();
        $data['status']=2;
        $data['audit_at']=time();
        Db::name('member_recharge')->where(array('id'=>$recharge['id']))->update($data);
        user_log($this->mid,'rechargedelete',1,'作废充值单 '.$id ,'manager');
        $this->success('处理成功！');
    }

    public function cashin($key=''){
        $model=Db::view('__MEMBER_CASHIN__ mc','*');
        $where=array();
        if(!empty($key)){
            $where['m.username']=array('LIKE',"%$key%");
        }

        $lists=$model->view('__MEMBER__ m',['username','realname'],'mc.member_id=m.id','LEFT')->order('id DESC')->paginate(15);


        $this->assign('lists',$lists);
        $this->assign('page',$lists->render());
        $total=Db::name('MemberCashin')->where(array('status'=>1))->sum('amount');
        $this->assign('total',$total);
        $this->assign('key',$key);
        return $this->fetch();
    }

    /**
     * 提现成功
     * @param string $id
     */
    public function cashupdate($id=''){
        $id=intval($id);
        if($id==0)$this->error('参数错误 ');
        $recharge=Db::name('member_cashin')->find($id);
        if(empty($recharge))$this->error('提现单不存在');
        if($recharge['status']!=0)$this->error('提现单已处理过了');

        $recharge=Db::name('member_cashin')->lock(true)->find($id);
        if($recharge['status']!=0)$this->error('提现单已处理过了');
        $data=array();
        $data['status']=1;
        $data['audit_at']=time();
        Db::name('member_cashin')->where(array('id'=>$recharge['id']))->update($data);
        user_log($this->mid,'cashaudit',1,'处理提现单 '.$id ,'manager');
        $this->success('处理成功！');
    }

    /**
     * 提现单作废并返还金额
     * @param string $id
     */
    public function cashdelete($id=''){
        $id=intval($id);
        if($id==0)$this->error('参数错误 ');
        $cash=Db::name('member_cashin')->find($id);
        if(empty($cash))$this->error('提现单不存在');
        if($cash['status']!=0)$this->error('提现单已处理过了');

        $cash=Db::name('member_cashin')->lock(true)->find($id);
        if($cash['status']!=0)$this->error('提现单已处理过了');
        $data['status']=2;
        Db::name('member_cashin')->where(array('id'=>$cash['id']))->update($data);

        money_log($cash['member_id'],$cash['amount'],'提现作废','cash');
        /*$member=Db::name('member')->lock(true)->where(array('id'=>$cash['member_id']))->find();
        if(!empty($member)){
            $mdata['money'] =$member['money']+$recharge['amount'];
            Db::name('member')->where(array('id'=>$member['id']))->save($mdata);
        }*/
        user_log($this->mid,'cashdelete',1,'作废提现单 '.$id ,'manager');
        $this->success('处理成功！');
    }
}