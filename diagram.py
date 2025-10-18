from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.database import Dynamodb
from diagrams.aws.network import APIGateway, Route53, CloudFront
from diagrams.aws.security import ACM
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.aws.general import Users

with Diagram("Multi-Region Serverless Static Website Architecture", show=True, direction="LR"):
    # Define users and Route53
    user = Users("End User")
    route53 = Route53("Route53\nFailover Policy")
    
    # Define CloudFront
    cloudfront = CloudFront("CloudFront\nDistribution")
    
    # S3 and ACM for us-east-1 (placed near east cluster)
    acm_east = ACM("ACM Certificate\nus-east-1")
    s3_east = S3("S3 Website\nus-east-1")
    
    with Cluster("us-east-1 Region"):
        api_east = APIGateway("API Gateway\nus-east-1")
        
        with Cluster("Lambda Functions us-east-1"):
            lambda_read1_east = Lambda("Lambda Read 1\nus-east-1")
            lambda_read2_east = Lambda("Lambda Read 2\nus-east-1")
            lambda_write1_east = Lambda("Lambda Write 1\nus-east-1")
            lambda_write2_east = Lambda("Lambda Write 2\nus-east-1")
        
        dynamodb_east = Dynamodb("Dynamodb\nGlobal Table\nus-east-1")
        cloudwatch_east = Cloudwatch("CloudWatch\nMetrics\nus-east-1")
    
    # S3 and ACM for us-west-2 (placed near west cluster)
    acm_west = ACM("ACM Certificate\nus-west-2")
    s3_west = S3("S3 Website\nus-west-2")
    
    with Cluster("us-west-2 Region"):
        api_west = APIGateway("API Gateway\nus-west-2")
        
        with Cluster("Lambda Functions us-west-2"):
            lambda_read1_west = Lambda("Lambda Read 1\nus-west-2")
            lambda_read2_west = Lambda("Lambda Read 2\nus-west-2")
            lambda_write1_west = Lambda("Lambda Write 1\nus-west-2")
            lambda_write2_west = Lambda("Lambda Write 2\nus-west-2")
        
        dynamodb_west = Dynamodb("Dynamodb\nReplica\nus-west-2")
        cloudwatch_west = Cloudwatch("CloudWatch\nMetrics\nus-west-2")
    
    # Define connections
    user >> route53
    route53 >> cloudfront

    # CloudFront to both S3 buckets and ACMs
    cloudfront >> acm_east
    cloudfront >> acm_west
    cloudfront >> s3_east
    cloudfront >> s3_west
    
    route53 >> Edge(color="blue", style="dashed", label="Primary") >> api_east
    route53 >> Edge(color="green", style="dashed", label="Failover") >> api_west
    
    # East region connections
    api_east >> lambda_read1_east
    api_east >> lambda_read2_east
    api_east >> lambda_write1_east
    api_east >> lambda_write2_east

    lambda_read1_east >> dynamodb_east
    lambda_read2_east >> dynamodb_east
    lambda_write1_east >> dynamodb_east
    lambda_write2_east >> dynamodb_east

    lambda_read1_east >> cloudwatch_east
    lambda_read2_east >> cloudwatch_east
    lambda_write1_east >> cloudwatch_east
    lambda_write2_east >> cloudwatch_east
    
    # West region connections
    api_west >> lambda_read1_west
    api_west >> lambda_read2_west
    api_west >> lambda_write1_west
    api_west >> lambda_write2_west

    lambda_read1_west >> dynamodb_west
    lambda_read2_west >> dynamodb_west
    lambda_write1_west >> dynamodb_west
    lambda_write2_west >> dynamodb_west

    lambda_read1_west >> cloudwatch_west
    lambda_read2_west >> cloudwatch_west
    lambda_write1_west >> cloudwatch_west
    lambda_write2_west >> cloudwatch_west

    # Dynamodb replication
    dynamodb_east >> Edge(color="red", style="dotted", label="Replication") >> dynamodb_west
