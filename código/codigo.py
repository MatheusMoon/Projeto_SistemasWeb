from diagrams import Diagram
from diagrams.aws.network import ELB
from diagrams.aws.network import APIGateway
from diagrams.aws.compute import Lambda
from diagrams.aws.compute import ECS
from diagrams.aws.database import Dynamodb


with Diagram("Arquitetura do Sistema de Pet Shop", show=False, filename="arquitetura_pet_shop"):
    lb = ELB("Balanceador de Carga")
    api_gateway = APIGateway("API Gateway")
    lambda_order = Lambda("Processar Pedidos")
    lambda_customer = Lambda("Gerenciar Clientes")
    ecs = ECS("Gerenciar Serviços de Pets")
    dynamodb = Dynamodb("Dados de Pets")

    lb >> api_gateway >> lambda_order
    lambda_order >> dynamodb
    api_gateway >> lambda_customer
    ecs << api_gateway

from IPython.display import Image

Image(filename='arquitetura_pet_shop.png')
