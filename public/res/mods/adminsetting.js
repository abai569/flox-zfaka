layui.define(['layer', 'table','form'], function(exports){
	var $ = layui.jquery;
	var layer = layui.layer;
	var table = layui.table;
	var form = layui.form;

	var savedPage = sessionStorage.getItem('setting_page');
	var currentPage = savedPage ? parseInt(savedPage) : 1;

	var tableIns = table.render({
		elem: '#setting',
		url: '/'+ADMIN_DIR+'/setting/ajax',
		page: {curr: currentPage},
		cellMinWidth:60,
		cols: [[
			{field: 'id', title: 'ID', width:80},
			{field: 'name', title: '参数'},
			{field: 'tag', title: '说明'},
			{field: 'updatetime', title: '更新时间', width:200, templet: '#updatetime',align:'center'},
			{field: 'opt', title: '操作', width:200, templet: '#opt',align:'center'}
		]],
		done: function(res, currPage, count){
			if(currPage) sessionStorage.setItem('setting_page', currPage);
			//监听分页变化
			var laypage = document.querySelector('.layui-laypage-curr');
			if(laypage && !laypage._observed){
				laypage._observed = true;
				new MutationObserver(function(){
					var em = laypage.querySelector('em');
					if(em && em.textContent) sessionStorage.setItem('setting_page', em.textContent);
				}).observe(laypage, {childList:true, subtree:true});
			}
		}
	});

	//修改
	form.on('submit(edit)', function(data){

		data.field.csrf_token = TOKEN;
		var i = layer.load(2,{shade: [0.5,'#fff']});
		$.ajax({
			url: '/'+ADMIN_DIR+'/setting/editajax',
			type: 'POST',
			dataType: 'json',
			data: data.field,
		})
		.done(function(res) {
			if (res.code == '1') {
				layer.open({
					title: '提示',
					content: '修改成功',
					btn: ['确定'],
					yes: function(index, layero){
					    window.location.href = '/'+ADMIN_DIR+'/setting';
					},
					cancel: function(){ 
					    window.location.href = '/'+ADMIN_DIR+'/setting';
					}
				});
			} else {
				layer.msg(res.msg,{icon:2,time:5000});
			}
		})
		.fail(function() {
			layer.msg('服务器连接失败，请联系管理员',{icon:2,time:5000});
		})
		.always(function() {
			layer.close(i);
		});

		return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
	});
	
    form.on('submit(repair)', function(data){
		data.field.csrf_token = TOKEN;
		data.field.method = 'repair';
		var i = layer.load(2,{shade: [0.5,'#fff']});
			$.ajax({
				url: '/'+ADMIN_DIR+'/setting/repairajax/',
				type: 'POST',
				dataType: 'json',
				data: data.field,
			})
			.done(function(res) {
				if (res.code == '1') {
					layer.open({
						type: 1
						,title: '修复数据'
						,offset: 'auto'
						,id: 'layerPayone' //防止重复弹出
						,content: '<div style="padding: 20px 100px;">'+res.msg+'</div>'
						,btn: '关闭'
						,btnAlign: 'c' //按钮居中
						,shade: 0.8 //不显示遮罩
						,yes: function(){
							location.reload();
						}
						,cancel: function(){ 
							location.reload();
						} 
					});
				} else {
					layer.msg(res.msg,{icon:2,time:5000});
				}
			})
			.fail(function() {
				layer.msg('服务器连接失败，请联系管理员',{icon:2,time:5000});
			})
			.always(function() {
				layer.close(i);
			});

			return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
    });
	exports('adminsetting',null)
});