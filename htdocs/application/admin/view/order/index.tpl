<extend name="public:base" />

<block name="body">

    <include file="public/bread" menu="order_index" title="订单列表" />

    <div id="page-wrapper">

        <div class="row">
            <div class="col-6">
                <div class="btn-group btn-group-sm" role="group" aria-label="Button group with nested dropdown">
                    <button id="btnGroupDrop1" type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        导出订单
                    </button>
                    <div class="dropdown-menu" aria-labelledby="btnGroupDrop1">
                        <a class="dropdown-item" href="{:url('order/export',['order_ids'=>$orderids])}" target="_blank" >导出本页</a>
                        <a class="dropdown-item" href="{:url('order/export',['status'=>1])}" target="_blank">导出未处理</a>
                        <a class="dropdown-item" href="{:url('order/export',['status'=>$status,'audit'=>$audit,'key'=>base64_encode($key)])}" target="_blank">导出筛选结果</a>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <form action="{:url('order/index')}" method="post">
                    <div class="form-row">
                        <div class="col-3 form-group">
                            <select name="audit" class="form-control form-control-sm">
                                <option value="">全部</option>
                                <option value="1"{$audit==='1'?' selected':''}>已审核</option>
                                <option value="0"{$audit==='0'?' selected':''}>未审核</option>
                            </select>
                        </div>
                        <div class="col-3 form-group">
                            <select name="status" class="form-control form-control-sm">
                                <option value="">全部</option>
                                <option value="1"{$status==='1'?' selected':''}>待发货</option>
                                <option value="2"{$status==='2'?' selected':''}>待收货</option>
                                <option value="3"{$status==='3'?' selected':''}>已完成</option>
                                <option value="-1"{$status==='-1'?' selected':''}>已失效</option>
                            </select>
                        </div>
                        <div class="col-6 form-group input-group input-group-sm">
                            <input type="text" class="form-control" name="key" placeholder="输入关键词搜索">
                            <span class="input-group-append">
                              <button class="btn btn-outline-secondary" type="submit"><i class="ion-md-search"></i></button>
                            </span>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <table class="table table-hover table-striped">
            <thead>
            <tr>
                <th width="50">编号</th>
                <th>商品</th>
                <th>会员</th>
                <th>价格/返奖额</th>
                <th>时间</th>
                <th width="160">状态</th>
                <th width="160">&nbsp;</th>
            </tr>
            </thead>
            <tbody>
            <volist name="lists" id="v">
                <tr>
                    <td>{$v.order_id}</td>
                    <td>
                        <volist name="v['products']" id="p">
                        <div class="media">
                            <div class="media-left">
                                <img class="media-object" src="{$p['product_image']}" alt="{$p['product_title']}">
                            </div>
                            <div class="media-body">
                                <h4 class="media-heading">{$p['product_title']}</h4>
                                <div>￥{$p['product_price']} &times; {$p['count']}件</div>
                            </div>
                        </div>
                        </volist>
                    </td>
                    <td>
                        [{$v.member_id}]{$v['username']}
                    </td>
                    <td>{$v.payamount}<br />{$v.commission_amount}</td>
                    <td>{$v.create_time|showdate}</td>
                    <td>
                        {$v.status|order_status|raw}
                        <if condition="$v['isaudit'] EQ 1">
                            <span class="badge badge-secondary">已审核</span>
                            <else/>
                            <span class="badge badge-warning">待审核</span>
                        </if>
                        <if condition="$v['rebated'] EQ 1">
                            <span class="badge badge-success">已返奖</span>
                            <else/>
                            <span class="badge badge-warning">未返奖</span>
                        </if>
                    </td>
                    <td class="operations">
                        <a class="btn btn-outline-primary" title="详情" href="{:url('order/detail',array('id'=>$v['order_id']))}"><i class="ion-md-document"></i> </a>
                        <a class="btn btn-outline-primary btn-status" title="状态" href="javascript:" data-id="{$v.order_id}"  data-status="{$v['status']+1}"><i class="ion-md-checkbox-outline"></i> </a>
                        <if condition="$v['rebated'] NEQ 1">
                            <a class="btn btn-outline-success btn-audit" title="审核" href="javascript:" data-id="{$v.order_id}"  data-status="1"><i class="ion-md-checkmark-circle"></i> </a>
                        </if>
                        <a class="btn btn-outline-danger link-confirm" title="删除" data-confirm="您真的确定要删除吗？\n删除后将不能恢复!" href="{:url('order/delete',array('id'=>$v['order_id']))}"><i class="ion-md-trash"></i> </a>
                    </td>
                </tr>
            </volist>
            </tbody>
        </table>
        {$page|raw}
    </div>
</block>
<block name="script">
        <script type="text/plain" id="orderStatus">
            <div class="row" style="margin:0 20%;">
                <div class="col-12 form-group"> 
                    <select class="form-control status-id">
                        <option value="0">待支付</option>
                        <option value="1">已支付</option>
                        <option value="2">已发货</option>
                        <option value="3">已完成</option>
                        <option value="-1">订单作废</option>
                    </select>
                </div>
                <div class="col-12 form-group express_row">
                    <div class="input-group">
                        <div class="input-group-prepend"><span class="input-group-text">快递公司</span></div>
                        <select class="form-control express-code">
                            <option value="">无需快递</option>
                            <foreach name="expresscodes" item="exp" key="k">
                                <option value="{$k}">{$exp}</option>
                            </foreach>
                        </select>
                    </div>
                </div> 
                <div class="col-12 form-group express_row express_no">
                    <div class="input-group">
                        <div class="input-group-prepend"><span class="input-group-text">快递单号</span></div>
                        <input type="text" class="form-control express-no" placeholder="如需物流，请填写单号"/>
                    </div>
                </div> 
            </div>
        </script>
    <script type="text/javascript">
        jQuery(function(){
            
            var tpl=$('#orderStatus').text();
            $('.btn-status').click(function() {
                var id=$(this).data('id');
                var status=$(this).data('status');
                var dlg=new Dialog({
                    onshown:function(body){
                        var select=body.find('select.status-id');
                        var express_code=body.find('.express-code');
                        express_code.change(function(){
                            if($(this).val()){
                                body.find('.express_no').show();
                            }else{
                                body.find('.express_no').hide();
                            }
                        });
                        select.val(status);
                        select.change(function(){
                            if(select.val()=='2'){
                                body.find('.express_row').show();
                                express_code.trigger('change');
                            }else{
                                body.find('.express_row').hide();
                            }
                        }).trigger('change');
                    },
                    onsure:function(body){
                        var data={
                                id:id,
                                status:body.find('select.status-id').val()
                            };
                            if(data.status==2){
                                data['express_code']=body.find('select.express-code').val();
                                data['express_no']=body.find('.express-no').val();
                            }
                        $.ajax({
                            url:'{:url("status")}',
                            type:'POST',
                            data:data,
                            dataType:'JSON',
                            success:function(){
                                dlg.hide();
                                location.reload();
                            }
                        })
                    }
                }).show(tpl,'订单状态');
            });

            var tpl2='<div class="row" style="margin:0 20%;">' +
                '<div class="col form-group"> <select class="form-control status-id"><option value="0">待审核</option><option value="1">已审核</option></select></div>' +
                '</div>';
            $('.btn-audit').click(function() {
                var id=$(this).data('id');
                var status=$(this).data('status');
                var dlg=new Dialog({
                    onshown:function(body){
                        var select=body.find('select.status-id');
                        select.val(status);
                    },
                    onsure:function(body){
                        $.ajax({
                            url:'{:url("audit")}',
                            type:'POST',
                            data:{
                                id:id,
                                status:body.find('select.status-id').val(),
                            },
                            dataType:'JSON',
                            success:function(){
                                dlg.hide();
                                location.reload();
                            }
                        })
                    }
                }).show(tpl2,'订单审核');
            });
        });
    </script>

</block>