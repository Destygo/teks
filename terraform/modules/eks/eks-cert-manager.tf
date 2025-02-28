//
// [cert-manager]
//
resource "aws_iam_policy" "eks-cert-manager" {
  count  = var.cert_manager["create_iam_resources"] ? 1 : var.cert_manager["create_iam_resources_kiam"] ? 1 : 0
  name   = "terraform-eks-${var.cluster-name}-cert-manager"
  policy = var.cert_manager["iam_policy"]
}

resource "aws_iam_role_policy_attachment" "eks-cert-manager" {
  count      = var.cert_manager["create_iam_resources"] ? 1 : 0
  role       = aws_iam_role.eks-node[var.cert_manager["attach_to_pool"]].name
  policy_arn = aws_iam_policy.eks-cert-manager[0].arn
}

resource "aws_iam_role" "eks-cert-manager-kiam" {
  name  = "terraform-eks-${var.cluster-name}-cert-manager-kiam"
  count = var.cert_manager["create_iam_resources_kiam"] ? 1 : 0

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.eks-kiam-server-role[count.index].arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "eks-cert-manager-kiam" {
  count = var.cert_manager["create_iam_resources_kiam"] ? 1 : 0
  role = aws_iam_role.eks-cert-manager-kiam[count.index].name
  policy_arn = aws_iam_policy.eks-cert-manager[count.index].arn
}

output "cert-manager-kiam-role-arn" {
  value = aws_iam_role.eks-cert-manager-kiam.*.arn
}

