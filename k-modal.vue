<template>
    <div v-if="computedVisible" :class="{ 'mask-dialog': isDialog }">

        <div v-if="computedVisible" id="drag" :class="modalClass" :style="mergedModalStyle">
            <div class="mask-header">
                <slot name="mask-Header">
                    <h2>{{ title }}</h2>
                    <div>
                        <a class="min" href="javascript:;" title="最小化" >
                            <icon-minus-circle />
                        </a>
                        <a class="max" href="javascript:;" title="最大化" >
                            <icon-fullscreen />
                        </a>
                        <a class="revert" href="javascript:;" title="还原" >
                            <icon-fullscreen-exit />
                        </a>
                        <a class="close" href="javascript:;" title="关闭" >
                            <icon-close-circle />
                        </a>
                    </div>
                </slot>
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
                <slot />
            </div>
            <div v-if="footer" class="mask-footer">
                <slot name="mask-footer">
                    <a-space>
                        <a-button @click="handleCancle">取消</a-button>
                        <a-button :loading="mergedOkLoading" type="primary" @click="handleOK">确定</a-button>
                    </a-space>
                </slot>
            </div>
        </div>
    </div>
</template>

<script setup lang='ts'>
import { reactive, ref, onMounted, computed, watch, nextTick } from 'vue'
import { isNumber } from '@/utils/is'

interface Props {
    visible?: boolean
    title?: string
    isDialog?: boolean
    width?: string | number
    style?: any
    defaultVisible?: boolean
    isFullScreen?: boolean
    loading?:boolean
    footer?:boolean
    
}
const props = withDefaults(defineProps<Props>(), {
    visible: false,
    title: '',      // 标题
    isDialog: false, // 是否需要蒙层
    defaultVisible: false,
    isFullScreen: true, // 是否最大化，默认最大化
    loading:false,
    footer:true,
    style: () => {
        return {}
    }
})
const modalClass = computed(() => [
    'mask-box',
    {
        ['modal-screen']: props.isFullScreen
    }
])
const emits = defineEmits(['handleCancel', 'update:visible', 'cancel', 'ok'])

const boxHeight = ref<number>(0)
const boxWidth = ref<number>(0)


const _okLoading = ref(false);
const mergedOkLoading = computed(() => props.loading || _okLoading.value);

const _visible = ref(props.defaultVisible);
const computedVisible = computed(() => props.visible ?? _visible.value);

let promiseNumber = 0;
// 关闭弹窗
const close = () => {
    promiseNumber++;
    if (_okLoading.value) {
        _okLoading.value = false;
      }
      _visible.value = false;
    emits('update:visible', false);
};

// 样式处理
const mergedModalStyle = computed(() => {
    const style: any = {
        ...(props.style ?? {}),
    };
    if (props.width) {
        style.width = isNumber(props.width) ? `${props.width}px` : props.width;
    }
    return style
})
// 关闭弹窗
const handleCancle = () => {
    emits('cancel')
    close()
}
// 确定
const handleOK = async()=>{
    emits('ok')
}

let x = '', y = ''; // 定义标志位
const dragMinWidth = 250;
const dragMinHeight = 124;

const Drag = (boxHtml: HTMLElement, boxTitle: HTMLElement, maskContent: HTMLElement, maskfooter: HTMLElement) => {
    const _this: any = window
    let disX = 0
    let disY = 0
    var oMin = <HTMLImageElement>boxHtml.querySelector(".min");
    var oMax = <HTMLImageElement>boxHtml.querySelector(".max");
    var oRevert = <HTMLImageElement>boxHtml.querySelector(".revert");
    var oClose = <HTMLImageElement>boxHtml.querySelector(".close");
    const maskDialog = <HTMLImageElement>document.querySelector('.mask-dialog')
    boxTitle = boxTitle || boxHtml
    boxTitle.style.cursor = 'move'
    // 监听鼠标按下并移动
    boxTitle.onmousedown = (event: MouseEvent) => {
        // 阻止默认事件
        const ev = event || window.event
        // 获取当前鼠标点击X，y轴值 并减去绝对布局的偏移量
        disX = event.clientX - boxHtml.offsetLeft
        disY = event.clientY - boxHtml.offsetTop
        document.onmousemove = (e) => {
            const moveEvent = e || window.event
            // 获取移动的X，Y轴距离  
            let moveX = e.clientX - disX
            let moveY = e.clientY - disY
            // 获取文档的宽度高度 - 元素布局宽度
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
        document.onmouseup = () => {
            document.onmousemove = null
            document.onmouseup = null
            // 释放鼠标捕获，让鼠标恢复通常鼠标输入处理
            _this.releaseCapture && _this.releaseCapture()
        }
        // 设置鼠标容器是否被捕获 主要用于 onmouseover 与 onmouseout 
        _this.setCapture && _this.setCapture();
        return false
    }
    //最大化按钮
    oMax.onclick = function () {
        boxHeight.value = boxHtml.offsetHeight
        boxWidth.value = boxHtml.offsetWidth

        boxHtml.style.top = boxHtml.style.left = '0';
        boxHtml.style.width = document.documentElement.clientWidth - 2 + "px";
        boxHtml.style.height = document.documentElement.clientHeight - 2 + "px";
        maskContent.style.height = (boxHtml.offsetHeight -(maskfooter!=null? maskfooter.offsetHeight:0) - boxTitle.offsetHeight - 10) + 'px'
        oMax.style.display = "none";
        oRevert.style.display = "block";
    };
    //还原按钮
    oRevert.onclick = function ()
    {        
        boxHtml.style.width = boxWidth.value + "px";
        boxHtml.style.height = boxHeight.value + "px";
        boxHtml.style.left = (document.documentElement.clientWidth - boxHtml.offsetWidth) / 2 + "px";
        boxHtml.style.top = (document.documentElement.clientHeight - boxHtml.offsetHeight) / 2 + "px";
        maskContent.style.height = (boxHtml.offsetHeight - (maskfooter!=null? maskfooter.offsetHeight:0) - boxTitle.offsetHeight - 10) + 'px'
        oRevert.style.display = "none";
        oMax.style.display = "block";
    };
    // 
    oClose.onclick = function(){
        // boxHtml.style.display = "none";
        close()
        emits('cancel')
        if(maskDialog!=null){
            maskDialog.style.display = 'none'
            // maskDialog.remove()
        }
        // else{
        //     boxHtml.remove()
        // }
       
    }
    //最小化按钮
    oMin.onclick  = function ()
    {
        boxHtml.style.display = "none";
        if(maskDialog!=null){
            maskDialog.style.display = 'none'
        }
        var oA = document.createElement("a");
        oA.className = "k-modal-open";
        oA.href = "javascript:;";
        oA.title = "还原";
        oA.innerText = props.title
        document.body.appendChild(oA);
        oA.onclick = function ()
        {
            boxHtml.style.display = "block";
            if(maskDialog!=null){
             maskDialog.style.display = 'block'
            }
            document.body.removeChild(oA);
            this.onclick = null;
        };
    };
    //阻止冒泡
    oMin.onmousedown = oMax.onmousedown = oClose.onmousedown = function (event: MouseEvent) {
        oMin.onfocus = function () { oMin.blur() };
        (event || window.event).cancelBubble = true
    };
}
// 改变文档大小
function resize(boxHtml: HTMLElement, maskHeader: HTMLElement, maskContent: HTMLElement, maskFooter: HTMLElement, resizeHtml: HTMLElement, isLeft: boolean, isTop: boolean, lockX: boolean, lockY: boolean) {

    resizeHtml.onmousedown = (event: MouseEvent) => {
        const ev = event || window.event
        // 获取当前鼠标点击X，y轴值 并减去绝对布局的偏移量
        let disX = event.clientX - resizeHtml.offsetLeft
        let disY = event.clientY - resizeHtml.offsetTop

        // 获取元素的偏移量和布局宽高
        let resizeLeft = boxHtml.offsetLeft
        let resizeTop = boxHtml.offsetTop
        let resizeWd = boxHtml.offsetWidth
        let resizeHt = boxHtml.offsetHeight

        if (event.clientX > resizeLeft + resizeWd - 10) {
            x = 'right'
            boxHtml.style.cursor = 'e-resize'
        } else if (event.clientX < resizeLeft + resizeWd + 10) {
            x = 'left'
            boxHtml.style.cursor = 'e-resize'
        }
        if (event.clientY > resizeTop + resizeHt - 10) {

            y = 'bottom';
            boxHtml.style.cursor = 's-resize';
        }
        else if (event.clientY < resizeTop + 10) {

            y = 'top';
            boxHtml.style.cursor = 's-resize';
        }
        document.onmousemove = (e: MouseEvent) => {
            const moveEvent = e || window.event
            let moveLeft = e.clientX - disX
            let moveTop = e.clientY - disY
            // 获取头部，底部高度
            let headHt = maskHeader.offsetHeight
            let footHt = (maskFooter!=null? maskFooter.offsetHeight:0)
            // let moveWd = boxHtml.offsetWidth 
            let moveHt = y === 'bottom' ? resizeHt + (e.clientY - event.clientY) : (e.clientY > 0 ? resizeHt - (e.clientY - event.clientY) : resizeHt + event.clientY)
            let moveWd = x === 'right' ? resizeWd + (e.clientX - event.clientX) : resizeWd - (e.clientX - event.clientX)
            const maxW = document.documentElement.clientWidth - boxHtml.offsetLeft - 2
            const maxH = document.documentElement.clientHeight - boxHtml.offsetTop - 2
            console.log(maxH)
            moveWd < dragMinWidth && (moveWd = dragMinWidth)
            moveWd > maxW && (moveWd = maxW)
            lockX || (boxHtml.style.width = moveWd + 'px')
            moveHt < dragMinHeight && (moveHt = dragMinHeight)
            moveHt > maxH && (moveHt = maxH)
            console.log(footHt)
            maskContent.style.height = (moveHt - headHt - footHt - 10) + 'px'
            lockY || (boxHtml.style.height = moveHt + 'px')
            if ((isLeft && moveWd == dragMinWidth) || (isTop && moveHt == dragMinHeight)) {
                document.onmousemove = null
                return false
            }
            isLeft && (boxHtml.style.left = resizeLeft + moveLeft + 'px')
            isTop && (boxHtml.style.top = e.clientY <= 0 ? '0' : resizeTop + moveTop + 'px')
            return false
        };
        document.onmouseup = () => {
            document.onmousemove = null
            document.onmouseup = null
        }
        return false
    }
}

const initData = () => {
    // document.querySelector
    const maskBox = <HTMLImageElement>document.getElementsByClassName('mask-box')[0]
    // if (maskBox!=null) {
    const maskHeader = <HTMLImageElement>maskBox.querySelector('.mask-header')
    const maskContent = <HTMLImageElement>maskBox.querySelector('.mask-content')
    const maskfooter = <HTMLImageElement>maskBox.querySelector('.mask-footer')
    const ml = <HTMLImageElement>maskBox.querySelector('.mask-resize-Left')
    const mt = <HTMLImageElement>maskBox.querySelector('.mask-resize-Top')
    const mr = <HTMLImageElement>maskBox.querySelector('.mask-resize-Right')
    const mb = <HTMLImageElement>maskBox.querySelector('.mask-resize-Bottom')
    const mlt = <HTMLImageElement>maskBox.querySelector('.mask-resize-LT')
    const mtr = <HTMLImageElement>maskBox.querySelector('.mask-resize-TR')
    const mbr = <HTMLImageElement>maskBox.querySelector('.mask-resize-BR')
    const mlb = <HTMLImageElement>maskBox.querySelector('.mask-resize-LB')

    Drag(maskBox, maskHeader, maskContent, maskfooter)
    //四角
    resize(maskBox, maskHeader, maskContent, maskfooter, mlt, true, true, false, false);
    resize(maskBox, maskHeader, maskContent, maskfooter, mtr, false, true, false, false);
    resize(maskBox, maskHeader, maskContent, maskfooter, mbr, false, false, false, false);
    resize(maskBox, maskHeader, maskContent, maskfooter, mlb, true, false, false, false);
    // 四边修改宽高
    resize(maskBox, maskHeader, maskContent, maskfooter, ml, true, false, false, true);
    resize(maskBox, maskHeader, maskContent, maskfooter, mt, false, true, true, false);
    resize(maskBox, maskHeader, maskContent, maskfooter, mr, false, false, false, true);
    resize(maskBox, maskHeader, maskContent, maskfooter, mb, false, false, true, false);
    maskBox.style.left = (document.documentElement.clientWidth - maskBox.offsetWidth) / 2 + 'px'
    maskBox.style.top = (document.documentElement.clientHeight - maskBox.offsetHeight) / 2 + 'px'
    // }
}
watch(() => props.visible, () => {
    // alert(props.visible)
    if (props.visible) {
        nextTick(() => {
            initData()
        })

    }
})
// onMounted(()=>{
//     initData()
// })
</script>

<style lang='less' scoped>
body,
div,
h2 {
    margin: 0;
    padding: 0;
}


#drag {
    position: absolute;
    top: 100px;
    left: 100px;
    width: 300px;
    // height: 160px;
    background: #fff;
    border: 1px solid #444;
    border-radius: 5px;
    box-shadow: 0 1px 3px 2px #666;
    z-index: 999;
}

#drag .mask-header {
    position: relative;
    height: 40px;
    margin: 5px;
    border-bottom: 1px solid #A1B4B0;
    display: flex;
    align-items: center;
    h2{
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
}

// #drag .mask-header h2 {
//     font-size: 14px;
//     height: 27px;
//     line-height: 24px;
// }

// #drag .mask-header div {
//     position: absolute;
//     height: 19px;
//     top: 2px;
//     right: 0;
// }



#drag .mask-header a.min {
    background-position: -29px 0;
}

#drag .mask-header a.min:hover {
    background-position: -29px -29px;
}

#drag .mask-header a.max {
    background-position: -60px 0;
}

#drag .mask-header a.max:hover {
    background-position: -60px -29px;
}

#drag .mask-header a.revert {
    background-position: -149px 0;
    display: none;
}

#drag .mask-header a.revert:hover {
    background-position: -149px -29px;
}

#drag .mask-header a.close {
    background-position: -89px 0;
}

#drag .mask-header a.close:hover {
    background-position: -89px -29px;
}

#drag .mask-content {
    // overflow: auto;
    // margin: 0 5px;
    // position: relative;
    padding: 15px 10px;
    overflow: auto;
    font-size: 14px;
    box-sizing: border-box;
    height: 100%;
}

#drag .mask-resize-BR {
    position: absolute;
    width: 14px;
    height: 14px;
    right: 0;
    bottom: 0;
    overflow: hidden;
    cursor: nw-resize;
    background: url(images/resize.png) no-repeat;
}

#drag .mask-resize-Left,
#drag .mask-resize-Top,
#drag .mask-resize-Right,
#drag .mask-resize-Bottom,
#drag .mask-resize-LT,
#drag .mask-resize-TR,
#drag .mask-resize-LB {
    position: absolute;
    background: #000;
    overflow: hidden;
    opacity: 0;
    filter: alpha(opacity=0);
}

#drag .mask-resize-Left,
#drag .mask-resize-Right {
    top: 0;
    width: 5px;
    height: 100%;
    cursor: w-resize;
}

#drag .mask-resize-Right {
    right: 0;
}

#drag .mask-resize-Top,
#drag .mask-resize-Bottom {
    width: 100%;
    height: 5px;
    cursor: n-resize;
}

#drag .mask-resize-Top {
    top: 0;
}

#drag .mask-resize-Bottom {
    bottom: 0;
}

#drag .mask-resize-LT,
#drag .mask-resize-TR,
#drag .mask-resize-LB {
    width: 8px;
    height: 8px;
    background: #FF0;
}

#drag .mask-resize-LT {
    top: 0;
    left: 0;
    cursor: nw-resize;
}

#drag .mask-resize-TR {
    top: 0;
    right: 0;
    cursor: ne-resize;
}

#drag .mask-resize-LB {
    left: 0;
    bottom: 0;
    cursor: ne-resize;
}

.mask-footer {
    // width: 100%;
    // position: absolute;
    // bottom: 0;
    // left: 0;
    // right: 0;
    // height: 34px;
    text-align: right;
    box-sizing: border-box;
    flex-shrink: 0;
    width: 100%;
    padding: 5px 10px;
    text-align: right;
    border-top: 1px solid #dcdfe6;
}

.mask-dialog {
    width: 100%;
    height: 100%;
    position: fixed;
    background: rgba(0, 0, 0, 0.45);
    top: 0;
    right: 0;
    z-index: 999;
}

.modal-screen {
    top: 0;
    display: inline-flex;
    flex-direction: column;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
}
</style>
