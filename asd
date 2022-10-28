<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
       body,div,h2{margin:0;padding:0;}
body{background:url(images/bg.jpg);font:12px/1.5 \5fae\8f6f\96c5\9ed1;color:#333;}
#drag{position:absolute;top:100px;left:200px;width:300px;height:160px;background:#e9e9e9;border:1px solid #444;border-radius:5px;box-shadow:0 1px 3px 2px #666;}
#drag .title{position:relative;height:27px;margin:5px;}
#drag .title h2{font-size:14px;height:27px;line-height:24px;border-bottom:1px solid #A1B4B0;}
#drag .title div{position:absolute;height:19px;top:2px;right:0;}
#drag .title a,a.open{float:left;width:21px;height:19px;display:block;margin-left:5px;background:url(images/tool.png) no-repeat;}
a.open{position:absolute;top:10px;left:50%;margin-left:-10px;background-position:0 0;}
a.open:hover{background-position:0 -29px;}
#drag .title a.min{background-position:-29px 0;}
#drag .title a.min:hover{background-position:-29px -29px;}
#drag .title a.max{background-position:-60px 0;}
#drag .title a.max:hover{background-position:-60px -29px;}
#drag .title a.revert{background-position:-149px 0;display:none;}
#drag .title a.revert:hover{background-position:-149px -29px;}
#drag .title a.close{background-position:-89px 0;}
#drag .title a.close:hover{background-position:-89px -29px;}
#drag .content{overflow:auto;margin:0 5px;}
#drag .mask-resize-BottomR{position:absolute;width:14px;height:14px;right:0;bottom:0;overflow:hidden;cursor:nw-resize;background:url(images/resize.png) no-repeat;}
#drag .mask-resize-Left,#drag .mask-resize-Top,#drag .mask-resize-Right,#drag .mask-resize-Bottom,#drag .mask-resize-LT,#drag .mask-resize-TopR,#drag .mask-resize-LeftB{position:absolute;background:#000;overflow:hidden;opacity:0;filter:alpha(opacity=0);}
#drag .mask-resize-Left,#drag .mask-resize-Right{top:0;width:5px;height:100%;cursor:w-resize;}
#drag .mask-resize-Right{right:0;}
#drag .mask-resize-Top,#drag .mask-resize-Bottom{width:100%;height:5px;cursor:n-resize;}
#drag .mask-resize-Top{top:0;}
#drag .mask-resize-Bottom{bottom:0;}
#drag .mask-resize-LT,#drag .mask-resize-TopR,#drag .mask-resize-LeftB{width:8px;height:8px;background:#FF0;}
#drag .mask-resize-LT{top:0;left:0;cursor:nw-resize;}
#drag .mask-resize-TopR{top:0;right:0;cursor:ne-resize;}
#drag .mask-resize-LeftB{left:0;bottom:0;cursor:ne-resize;}
    </style>
    <title>拖拽测试</title>
</head>

<body>
    <div id="drag" class="mask-box">
        <div class="mask-header">
            <h2>这是一个可以拖动的窗口</h2>
            <div>
                <!-- <a class="min" href="javascript:;" title="最小化"></a>
            <a class="max" href="javascript:;" title="最大化"></a>
            <a class="revert" href="javascript:;" title="还原"></a> -->
                <a class="close" href="javascript:;" title="关闭"></a>
            </div>
        </div>
        <div class="mask-resize-Left"></div>
        <div class="mask-resize-Top"></div>
        <div class="mask-resize-Right"></div>
        <div class="mask-resize-Bottom"></div>
        <div class="mask-resize-LT"></div>
        <div class="mask-resize-TR"></div>
        <div class="mask-resize-BR"></div>
        <div class="mask-resize-LB"></div>
        <div class="mask-content">
            ① 窗口可以拖动；<br />
            ② 窗口可以通过八个方向改变大小；<br />
            ③ 窗口可以最小化、最大化、还原、关闭；<br />
            ④ 限制窗口最小宽度/高度。
        </div>
    </div>
    <script>
        var dragMinWidth = 250;
        var dragMinHeight = 124;
        // 拖拽，点击头部样式改变
        function Drag(boxHtml,boxTitle){
            let disX = 0
            let disY = 0
            boxTitle = boxTitle || boxHtml
            boxTitle.style.cursor = 'move'
            // 监听鼠标按下并移动
            boxTitle.onmousedown = (event)=>{
                // 阻止默认事件
                const ev = event || window.event
                // 获取当前鼠标点击X，y轴值 并减去绝对布局的偏移量
                disX = event.clientX - boxHtml.offsetLeft 
                disY = event.clientY - boxHtml.offsetTop
                document.onmousemove = (e)=>{
                    const moveEvent = e || window.event
                    // 获取移动的X，Y轴距离  
                    let moveX = e.clientX - disX
                    let moveY = e.clientY - disY
                    // 获取文档的宽度高度 - 元素布局宽度
                    console.log(document.documentElement.clientWidth)
                    console.log(boxHtml.offsetWidth)
                    const maxX = document.documentElement.clientWidth - boxHtml.offsetWidth
                    const maxY = document.documentElement.clientHeight - boxHtml.offsetHeight
                    moveX <= 0 && (moveX = 0)
                    moveY <= 0 && (moveY = 0)
                    moveX >= maxX && (moveX = maxX)
                    moveY >= maxY && (moveY = maxY)
                    boxHtml.style.left = moveX + 'px'
                    boxHtml.style.top = moveY + 'px'
                    return false
                };
                // 监听松开鼠标按钮
                document.onmouseup = ()=>{
                    document.onmousemove = null
                    document.onmouseup = null 
                    // 释放鼠标捕获，让鼠标恢复通常鼠标输入处理
                    this.releaseCapture && this.releaseCapture()
                }
                // 设置鼠标容器是否被捕获 主要用于 onmouseover 与 onmouseout 
                this.setCapture && this.setCapture();
                return false
            }

        }
        // 改变文档大小
        function resize(boxHtml, resizeHtml, isLeft, isTop, lockX, lockY){
            window.onmousedown = (event)=>{
                const ev = event || window.event
                  // 获取当前鼠标点击X，y轴值 并减去绝对布局的偏移量
                let disX = event.clientX - resizeHtml.offsetLeft 
                let disY = event.clientY - resizeHtml.offsetTop
                // 获取元素的偏移量和布局宽高
                let resizeLeft = boxHtml.offsetLeft
                let resizeTop = boxHtml.offsetTop
                let resizeWd = boxHtml.offsetWidth
                let resizeHt = boxHtml.offsetHeight
                document.onmousemove = (e)=>{
                    console.log('999')
                    const moveEvent = e || window.event
                    let moveLeft = e.clientX - disX
                    let moveTop = e.clientY - disY
                    let moveWd = resizeHtml.offsetWidth 
                    let moveHt = resizeHtml.offsetHeight 
                    const maxW = document.documentElement.clientWidth - boxHtml.offsetLeft - 2
                    const maxH = document.documentElement.clientHeight - boxHtml.offsetTop - 2
                    moveWd < dragMinWidth && (moveWd = dragMinWidth)
                    moveWd > maxW && ( moveWd = maxW )
                    lockX || ( resizeHtml.style.width = moveWd + 'px' )
                    moveHt < dragMinHeight && (moveHt = dragMinHeight)
                    moveHt > maxH && ( moveHt = maxH )
                    lockY || ( resizeHtml.style.height = moveHt + 'px')
                    if((isLeft && moveWd == dragMinWidth) || (isTop && moveHt==dragMinHeight)){
                        document.onmousemove = null
                        return false
                    }
                    isLeft && (resizeHtml.style.left = resizeLeft + moveLeft + 'px' )
                    isTop && (resizeHtml.style.top = resizeTop + moveTop + 'px' )
                    return false
                };
                document.onmouseup = ()=>{
                    document.onmousemove = null 
                    document.onmouseup = null
                }
                return false
            }
        }
        function initData(){
            document.querySelector
            const maskBox = document.getElementsByClassName('mask-box')[0]
            const maskHeader = maskBox.querySelector('.mask-header')
            const ml =  maskBox.querySelector('.mask-resize-Left')
            const mt =  maskBox.querySelector('.mask-resize-Top')
            const mr =  maskBox.querySelector('.mask-resize-Right')
            const mb =  maskBox.querySelector('.mask-resize-Bottom')
            const mlt =  maskBox.querySelector('.mask-resize-LT')
            const mtr =  maskBox.querySelector('.mask-resize-TR')
            const mbr =  maskBox.querySelector('.mask-resize-BR')
            const mlb =  maskBox.querySelector('.mask-resize-LB')
          
            Drag(maskBox, maskHeader)
            // 四边修改宽高
            resize(maskBox, ml, true, false, false, true);
            // resize(maskBox, mt, false, true, true, false);
            // resize(maskBox, mr, false, false, false, true);
            // resize(maskBox, mb, false, false, true, false);
            maskBox.style.left = ( document.documentElement.clientWidth - maskBox.offsetWidth )/2+ 'px'
            maskBox.style.top = ( document.documentElement.clientHeight - maskBox.offsetHeight )/2+ 'px'
        }
        window.onload = window.onresize =  initData()
    </script>
</body>

</html>
