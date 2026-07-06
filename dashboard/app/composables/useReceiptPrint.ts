/** Receipt print utility — generates thermal-receipt HTML and triggers browser print. */

const PAYMENT_LABELS: Record<string, string> = {
  cash: '现金',
  wechat: '微信',
  alipay: '支付宝',
  member_card: '会员卡',
}

interface ReceiptItem {
  product_name: string
  spec_name: string
  quantity: string | number
  price: string | number
  subtotal: string | number
}

interface ReceiptData {
  order_no: string
  total_amount: string | number
  discount_amount: string | number
  paid_amount: string | number
  payment_method: string
  paid_at: string
  cashier_name: string
  member_name?: string
  member_phone?: string
  member_card_no?: string
  member_points_earned?: number
  items: ReceiptItem[]
}

interface PrinterSettings {
  name: string
  address?: string
  phone?: string
  business_hours?: string
  paper_width: string
  print_logo: boolean
  print_barcode: boolean
  footer_text?: string
}

function maskPhone(phone: string): string {
  if (!phone || phone.length < 7) return phone
  return phone.slice(0, 3) + '****' + phone.slice(-4)
}

function fmtCurrency(v: string | number): string {
  return Number(v).toFixed(2)
}

function fmtDateTime(iso: string): string {
  if (!iso) return ''
  const d = new Date(iso)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function generateHtml(order: Record<string, any>, settings: PrinterSettings): string {
  const width = settings.paper_width === '80' ? '360px' : '280px'
  const items = order.items || []
  const discount = Number(order.discount_amount) || 0
  const hasMember = !!(order.member_name || order.member_phone)
  const phone = maskPhone(order.member_phone || '')

  const itemsHtml = items.map((i: Record<string, any>) => {
    const name = (i.product_name + (i.spec_name ? ` ${i.spec_name}` : '')).slice(0, 16)
    const qty = Number(i.quantity)
    const price = fmtCurrency(i.price)
    const sub = fmtCurrency(i.subtotal)
    return `<tr>
      <td class="name">${name}</td>
      <td class="qty">${qty}</td>
      <td class="price">${price}</td>
      <td class="sub">${sub}</td>
    </tr>`
  }).join('')

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>小票打印</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:"SF Mono","Cascadia Code","Consolas",monospace;font-size:12px;color:#1a1a1a;background:#f5f5f5;display:flex;justify-content:center;padding:20px}
  .receipt{width:${width};background:#fff;padding:16px 12px}
  .center{text-align:center}
  .store-name{font-size:15px;font-weight:700;margin-bottom:2px}
  .store-info{font-size:10px;color:#666;line-height:1.6}
  .hr{border:none;border-top:1px dashed #ccc;margin:10px 0}
  .order-meta{font-size:10px;color:#555;line-height:1.7}
  table{width:100%;border-collapse:collapse;font-size:10px}
  th{text-align:left;font-weight:600;padding:3px 0;border-bottom:1px solid #ddd;font-size:10px}
  td{padding:2px 0;vertical-align:top;font-size:10px}
  td.name{max-width:100px;word-break:break-all}
  td.qty{text-align:center;width:24px}
  td.price{text-align:right;width:44px}
  td.sub{text-align:right;width:50px;font-weight:500}
  .summary{font-size:11px;line-height:2}
  .summary-row{display:flex;justify-content:space-between}
  .summary-row.total{font-size:13px;font-weight:700;margin-top:2px}
  .member{font-size:10px;color:#555;line-height:1.7}
  .barcode-box{text-align:center;padding:6px 0}
  .barcode-text{font-family:"Courier New",monospace;font-size:18px;letter-spacing:3px;font-weight:700;padding:4px 8px;border:1px solid #333;display:inline-block}
  .footer{font-size:10px;color:#666;text-align:center;line-height:1.7;margin-top:4px}
  @media print{
    body{background:#fff;padding:0}
    .receipt{box-shadow:none}
  }
</style></head><body>
<div class="receipt">

  <!-- Header -->
  <div class="center">
    <div class="store-name">${settings.name}</div>
    <div class="store-info">
      ${settings.address ? `<div>${settings.address}</div>` : ''}
      ${settings.phone ? `<div>客服：${settings.phone}</div>` : ''}
      ${settings.business_hours ? `<div>营业：${settings.business_hours}</div>` : ''}
    </div>
  </div>
  <hr class="hr">

  <!-- Order meta -->
  <div class="order-meta">
    <div>单号：${order.order_no}</div>
    <div>收银员：${order.cashier_name || '—'}</div>
    <div>时间：${fmtDateTime(order.paid_at)}</div>
  </div>
  <hr class="hr">

  <!-- Items -->
  <table>
    <thead><tr><th>商品</th><th class="qty">数量</th><th class="price">单价</th><th class="sub">金额</th></tr></thead>
    <tbody>${itemsHtml}</tbody>
  </table>
  <hr class="hr">

  <!-- Totals -->
  <div class="summary">
    <div class="summary-row"><span>件数：${items.length}</span><span>${items.reduce((s: number, i: Record<string, any>) => s + Number(i.quantity), 0)} 件</span></div>
    <div class="summary-row"><span>合计</span><span>¥${fmtCurrency(order.total_amount)}</span></div>
    ${discount > 0 ? `<div class="summary-row"><span>优惠</span><span>-¥${fmtCurrency(discount)}</span></div>` : ''}
    <div class="summary-row total"><span>实收</span><span>¥${fmtCurrency(order.paid_amount)}</span></div>
    <div class="summary-row"><span>支付</span><span>${PAYMENT_LABELS[order.payment_method] || order.payment_method}</span></div>
  </div>

  <!-- Member -->
  ${hasMember ? `<hr class="hr"><div class="member">
    ${order.member_name ? `<div>会员：${order.member_name}</div>` : ''}
    ${phone ? `<div>手机：${phone}</div>` : ''}
    ${order.member_card_no ? `<div>卡号：${order.member_card_no}</div>` : ''}
    ${order.member_points_earned ? `<div>本次积分：+${order.member_points_earned}</div>` : ''}
  </div>` : ''}

  <!-- Barcode -->
  ${settings.print_barcode ? `<hr class="hr"><div class="barcode-box">
    <div class="barcode-text">${order.order_no}</div>
  </div>` : ''}

  <!-- Footer -->
  ${settings.footer_text ? `<hr class="hr"><div class="footer">${settings.footer_text.replace(/\n/g, '<br>')}</div>` : ''}

</div>
<script>
(function(){
  var imgs=document.querySelectorAll('img');
  var loaded=0;
  function tryPrint(){
    loaded++;
    if(loaded>=imgs.length){
      setTimeout(function(){window.print();},200);
    }
  }
  if(imgs.length===0){window.print();}
  else{for(var i=0;i<imgs.length;i++){if(imgs[i].complete)tryPrint();else imgs[i].onload=tryPrint;}}
})();
</script>
</body></html>`
}

export function openReceiptPrint(order: Record<string, any>, settings: PrinterSettings): boolean {
  const html = generateHtml(order, settings)
  const w = window.open('', '_blank', 'width=420,height=700')
  if (!w) return false
  w.document.write(html)
  w.document.close()
  w.focus()
  return true
}

export function useReceiptPrint() {
  return { openReceiptPrint }
}
