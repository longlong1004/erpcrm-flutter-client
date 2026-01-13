enum ProductStatus {
  // 申请上架流程状态
  draft('草稿'),
  pendingBasicInfoApproval('待审核基本信息'),
  pendingImageUpload('待上传图片'),
  pendingImageApproval('待审核图片'),
  pendingClerkProcess('待文员处理'),
  pendingRailwayUpload('待上传国铁'),
  pendingRailwayApproval('待国铁审核'),
 listed('已上架'),
  rejected('已驳回'),
  uploadFailed('上传失败'),
  
  // 回收站相关状态
  deleted('已删除'),
  abolished('已废除'),
  recalled('已撤回');
  
  final String label;
  
  const ProductStatus(this.label);
  
  static ProductStatus fromString(String status) {
    return values.firstWhere(
      (e) => e.name == status || e.label == status,
      orElse: () => draft,
    );
  }
  
  bool get isEditable => [
        draft,
        pendingBasicInfoApproval,
        pendingImageUpload,
        pendingClerkProcess,
        deleted,
        abolished,
        recalled,
      ].contains(this);
  
  bool get isApprovalRequired => [
        pendingBasicInfoApproval,
        pendingImageApproval,
        pendingRailwayApproval,
      ].contains(this);
  
  bool get isPending => [
        pendingBasicInfoApproval,
        pendingImageUpload,
        pendingImageApproval,
        pendingClerkProcess,
        pendingRailwayUpload,
        pendingRailwayApproval,
      ].contains(this);
}
