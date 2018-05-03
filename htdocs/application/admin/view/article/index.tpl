<extend name="public:base" />

<block name="body">
<include file="public/bread" menu="article_index" title="文章列表" />
<div id="page-wrapper">

	<div class="row list-header">
		<div class="col-6">
			<div class="btn-toolbar" role="toolbar" aria-label="Toolbar with button groups">
				<div class="btn-group btn-group-sm mr-2" role="group" aria-label="check action group">
					<a href="javascript:" class="btn btn-outline-secondary">全选</a>
					<a href="javascript:" class="btn btn-outline-secondary">反选</a>
				</div>
				<div class="btn-group btn-group-sm mr-2" role="group" aria-label="action button group">
					<a href="javascript:" class="btn btn-outline-secondary">发布</a>
					<a href="javascript:" class="btn btn-outline-secondary">撤销</a>
					<a href="javascript:" class="btn btn-outline-secondary">删除</a>
				</div>
				<a href="{:url('article/add')}" class="btn btn-outline-primary btn-sm">添加文章</a>
			</div>
		</div>
		<div class="col-6">
			<form action="{:url('article/index')}" method="post">
				<div class="form-row">
					<div class="col input-group input-group-sm mr-2">
						<div class="input-group-prepend">
							<span class="input-group-text">分类</span>
						</div>
						<select name="cate_id" class="form-control">
							<option value="0">不限分类</option>
							<foreach name="category" item="v">
								<option value="{$v.id}" {$cate_id == $v['id']?'selected="selected"':""}>{$v.html} {$v.title}</option>
							</foreach>
						</select>
					</div>
					<div class="col input-group input-group-sm">
						<input type="text" class="form-control" name="key" value="{$keyword}" placeholder="搜索标题、作者或分类">
						<div class="input-group-append">
							<button class="btn btn-outline-secondary" type="submit"><i class="ion-search"></i></button>
						</div>
					</div>
				</div>
			</form>
		</div>
	</div>
	<table class="table table-hover table-striped">
		<thead>
			<tr>
				<th width="50">编号</th>
				<th>标题</th>
				<th>类型</th>
				<th>发布时间</th>
				<th>作者</th>
				<th>分类</th>
				<th>状态</th>
				<th width="200">操作</th>
			</tr>
		</thead>
		<tbody>
			<foreach name="lists" item="v">
				<tr>
					<td>{$v.id}</td>
					<td>{$v.title}</td>
					<td>
						<if condition="$v.type eq 1"><span class="label label-default">普通</span>
							<elseif condition="$v.type eq 2" /><span class="label label-success">置顶</span>
							<elseif condition="$v.type eq 3" /><span class="label label-danger">热门</span>
							<elseif condition="$v.type eq 4" /><span class="label label-success">推荐</span>
						</if>
					</td>
					<td>{$v.time|showdate}</td>
					<td>{$v.username}</td>
					<td>{$v.category_title}</td>
					<td>
						<if condition="$v.status eq 1">
							<a class="btn btn-outline-warning btn-sm" href="{:url('article/push',array('id'=>$v['id']))}"><i class="ion-reply-all"></i> 撤销</a>
							<else/>
							<a class="btn btn-outline-success btn-sm" href="{:url('article/push',array('id'=>$v['id']))}"><i class="ion-paper-airplane"></i> 发布</a>
						</if>
					</td>

					<td>
					<a class="btn btn-outline-dark btn-sm" href="{:url('article/edit',array('id'=>$v['id']))}"><i class="ion-edit"></i> 编辑</a>
					<a class="btn btn-outline-dark btn-sm" href="{:url('article/delete',array('id'=>$v['id']))}" onclick="javascript:return del('您真的确定要删除吗？\n\n删除后将不能恢复!');"><i class="ion-trash-a"></i> 删除</a>
					</td>
				</tr>
			</foreach>
		</tbody>
	</table>
	<div class="clearfix"></div>
	{$page|raw}

</div>
</block>