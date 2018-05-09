<extend name="public:base"/>

<block name="body">
    <div class="main">
        <div class="subbanner">
            <div class="inner" style="background-image:url({:getAdImage('cases')})"></div>
        </div>

        <div class="nav-row">
            <div class="container">
                <div class="row">
                    <php>
                        if(empty($category)){ $catelist=$categories[0]; }
                        else { $catelist=$categories[$category['pid']];}
                    </php>
                    <Volist name="catelist" id="c">
                        <a class="col row-item {$c['name']==$category['name']?'active':''}" href="{:url('index/article/index',['name'=>$c['name']])}">{$c.title}</a>
                    </Volist>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="case-list">
                <ul class="row list-unstyled">
                    <php>$empty='<li class="col-12 empty">暂时没有内容</li>';</php>
                    <Volist name="lists" id="case" empty="$empty">
                        <li class="col-4">
                            <div class="card">
                                <img class="card-img-top" src="{$case.cover}" alt="Card image cap">
                                <div class="card-body">
                                    <h3 class="card-text">{$case.title}</h3>
                                    <p class="card-text text-muted">
                                        <span class="float-right"><i class="ion-ion-monitor"></i> <i
                                                    class="ion-iphone"></i> </span>
                                        <span>{$case.vice_title}</span>
                                    </p>
                                </div>
                                <a target="_blank" href="{:url('index/article/view',['id'=>$case['id']])}">
                                    <div class="mask"></div>
                                </a>
                            </div>
                        </li>
                    </Volist>
                </ul>
                {$page|raw}
            </div>
        </div>
    </div>
</block>