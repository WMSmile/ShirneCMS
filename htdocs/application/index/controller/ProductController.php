<?php
/**
 * Created by IntelliJ IDEA.
 * User: shirne
 * Date: 2018/5/13
 * Time: 9:55
 */

namespace app\index\controller;


use app\common\facade\ProductCategoryModel;
use app\common\model\ProductCommentModel;
use app\common\validate\ProductCommentValidate;
use think\Db;

class ProductController extends BaseController
{
    protected $categries;
    protected $category;
    protected $categotyTree;

    public function index($name=""){
        $this->category($name);

        $where=array();
        if(!empty($this->category)){
            $this->seo($this->category['title']);
            $where[]=array('product.cate_id','in',ProductCategoryModel::getSubCateIds($this->category['id']));
        }else{
            $this->seo("产品中心");
        }

        $model=Db::view('product','*')
            ->view('productCategory',['name'=>'category_name','title'=>'category_title'],'product.cate_id=productCategory.id','LEFT')
            ->view('manager',['username'],'manager.id=article.user_id','LEFT')
            ->where($where)
            ->paginate(10);

        $this->assign('lists', $model);
        $this->assign('page',$model->render());

        return $this->fetch();
    }

    public function view($id){
        $product = Db::name('product')->find($id);
        if(empty($product)){
            $this->error('商品不存在');
        }
        $this->seo($product['title']);
        $this->category($product['cate_id']);

        $this->assign('product', $product);
        return $this->fetch();
    }
    public function comment($id){
        $article = Db::name('product')->find($id);
        if(empty($article)){
            $this->error('参数错误');
        }
        if($this->request->isPost()){
            $data=$this->request->only('product_id,email,is_anonymous,content','POST');
            $validate=new ProductCommentValidate();
            if(!$validate->check($data)){
                $this->error($validate->getError());
            }else{
                $data['member_id']=$this->userid;
                if(empty($data['member_id'])){
                    $this->error('请先登录');
                }
                $model=ProductCommentModel::create($data);
                if($model->id){
                    $this->success('评论成功');
                }else{
                    $this->error('评论失败');
                }
            }
        }

        $comments=Db::view('productComment','*')
            ->view('member',['username','realname'],'member.id=articleComment.member_id','LEFT')
            ->where('product_id',$id)->paginate(10);

        $this->assign('comments',$comments);
        $this->assign('page',$comments->render());
        return $this->fetch();
    }

    private function category($name=''){

        $this->category=ProductCategoryModel::findCategory($name);
        $this->categotyTree=ProductCategoryModel::getCategoryTree($name);

        $this->categries=ProductCategoryModel::getTreedCategory();

        $this->assign('category',$this->category);
        $this->assign('categotyTree',$this->categotyTree);
        $this->assign('categories',$this->categries);
    }
}