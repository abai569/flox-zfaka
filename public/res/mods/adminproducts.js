layui.define(['layer', 'table', 'form','layedit','upload'], function(exports){
	var $ = layui.jquery;
	var layer = layui.layer;
	var table = layui.table;
	var form = layui.form;
	var layedit = layui.layedit;
	var upload = layui.upload;
	
	var edit_description=layedit.build('description',{
		tool: ['strong','italic','underline','|','del','left','center','right','link','unlink','face']
	});	 //建立编辑器
		
	table.render({
		elem: '#table',
		url: '/'+ADMIN_DIR+'/products/ajax',
		page: true,
		cellMinWidth:60,
		cols: [[
			{field: 'id', title: 'ID', width:80},
			{field: 'typename', title: '商品类型'},
			{field: 'name', title: '商品名称'},
			{field: 'price', title: '单价',width:80},
			{field: 'qty', title: '库存', width:80, templet: '#qty',align:'center'},
			{field: 'auto', title: '发货模式', width:100, templet: '#auto',align:'center'},
			{field: 'active', title: '是否销售', width:100, templet: '#active',align:'center'},
			{field: 'pifa', title: '批发', width:80,templet: '#pifa',align:'center'},
			{field: 'opt', title: '操作', width:120, templet: '#opt',align:'center'},
		]]
	});

	form.on('radio(stockcontrol)', function(data){
		if(data.value=='1'){
			var qty = $("#qty").attr("oldqty");
			$('#qty').val(qty);
			$("#qty").removeAttr("disabled");
		}else{
			$('#qty').val('0');
			$("#qty").attr("disabled","true");
		}
	});  
	
	form.on('radio(auto)', function(data){
		if(data.value=='1'){
			$('#addonsinput').hide();
		}else{
			$('#addonsinput').show();
		}
	});  
	
	//更新库存
	$("#products_form").on("click","#updateQty",function(event){
		event.preventDefault();
		var pid = $("#pid").val();
		$(this).attr({"disabled":"disabled"});
        $.ajax({
            type: "POST",
            dataType: "json",
            url: '/'+ADMIN_DIR+'/products/updateqtyajax',
            data: { "csrf_token": TOKEN,'pid':pid},
            success: function(res) {
                if (res.code == 1) {
					layer.open({
						title: '提示',
						content: '更新成功',
						btn: ['确定'],
						yes: function(index, layero){
							location.reload();
						},
						cancel: function(){ 
							location.reload();
						}
					});
                } else {
					layer.msg(res.msg,{icon:2,time:5000});
                }
                return;
            }
        });
	});
	
	//修改
	form.on('submit(edit)', function(data){
		layedit.sync(edit_description);
		data.field.csrf_token = TOKEN;
		data.field.description = layedit.getContent(edit_description);
		var i = layer.load(2,{shade: [0.5,'#fff']});
		$.ajax({
			url: '/'+ADMIN_DIR+'/products/editajax',
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
					    location.reload();
					},
					cancel: function(){ 
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
	
    form.on('submit(search)', function(data){
        table.reload('table', {
            url: '/'+ADMIN_DIR+'/products/ajax',
            where: data.field
        });
        return false;
    });
	
	
	var imageFiles = [];
	$('#select_product_images').on('click', function(){ $('#product_image_files').click(); });
	$('#product_image_files').on('change', function(){
		imageFiles = Array.prototype.slice.call(this.files || []);
		var oversized = imageFiles.some(function(file){ return file.size > 5 * 1024 * 1024; });
		var invalidType = imageFiles.some(function(file){ return ['image/jpeg','image/png','image/gif','image/webp'].indexOf(file.type) === -1; });
		var tooMany = imageFiles.length + Number($('#product_image_pid').data('image-count') || 0) > 6;
		if (oversized || invalidType || tooMany) {
			imageFiles = [];
			this.value = '';
			var message = oversized ? '单张图片不能超过5MB' : (invalidType ? '仅支持 JPG、PNG、GIF 和 WebP 图片' : '每个商品最多上传6张图片');
			layer.msg(message, {icon:2, time:5000});
		}
		$('#product_image_queue').text(imageFiles.length ? '已选择 '+imageFiles.length+' 张图片' : '');
		$('#upload_product_images').prop('disabled', !imageFiles.length).toggleClass('layui-btn-disabled', !imageFiles.length);
	});

	$('#upload_product_images').on('click', function(){
		if (!imageFiles.length) return;
		var pid = $('#product_image_pid').val();
		var loading = layer.load(2,{shade:[0.5,'#fff']});
		$('#select_product_images, #upload_product_images').prop('disabled', true).addClass('layui-btn-disabled');
		var index = 0;
		function finishUpload(message){
			layer.close(loading);
			$('#select_product_images').prop('disabled', false).removeClass('layui-btn-disabled');
			$('#upload_product_images').prop('disabled', !imageFiles.length).toggleClass('layui-btn-disabled', !imageFiles.length);
			if (message) layer.msg(message,{icon:2,time:5000});
		}
		function uploadNext(){
			if (index >= imageFiles.length) {
				finishUpload();
				location.reload();
				return;
			}
			$('#product_image_queue').text('正在上传 '+(index+1)+' / '+imageFiles.length);
			var formData = new FormData();
			formData.append('pid', pid);
			formData.append('csrf_token', TOKEN);
			formData.append('file', imageFiles[index]);
			$.ajax({url:'/'+ADMIN_DIR+'/productimages/upload', type:'POST', dataType:'json', data:formData, processData:false, contentType:false})
			.done(function(res){
				if (res.code == 1) { index++; uploadNext(); }
				else { finishUpload(res.msg); }
			})
			.fail(function(xhr){
				finishUpload(xhr.status === 413 ? '单张图片不能超过5MB' : '图片上传失败，请稍后重试');
			});
		}
		uploadNext();
	});

	function imageAction(action, id, extra){
		var data = $.extend({pid:$('#product_image_pid').val(), id:id, csrf_token:TOKEN}, extra || {});
		$.post('/'+ADMIN_DIR+'/productimages/'+action, data, function(res){
			if (res.code == 1) location.reload();
			else layer.msg(res.msg,{icon:2,time:5000});
		}, 'json').fail(function(){ layer.msg('操作失败，请稍后重试',{icon:2,time:5000}); });
	}
	$('#product_image_grid').on('click', '.set-primary', function(){ imageAction('primary', $(this).closest('.product-image-tile').data('id')); });
	$('#product_image_grid').on('click', '.move-image', function(){ imageAction('move', $(this).closest('.product-image-tile').data('id'), {direction:$(this).data('direction')}); });
	$('#product_image_grid').on('click', '.delete-image', function(){
		var id = $(this).closest('.product-image-tile').data('id');
		layer.confirm('确定删除这张图片吗？', function(){ imageAction('delete', id); });
	});
	
	exports('adminproducts',null)
});
