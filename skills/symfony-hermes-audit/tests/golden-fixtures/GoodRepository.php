<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Order;
use App\Enum\OrderStatus;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Order>
 */
final class GoodRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Order::class);
    }

    /**
     * @return list<Order>
     */
    public function findActiveWithCustomer(int $limit = 50): array
    {
        /** @var list<Order> $orders */
        $orders = $this->createQueryBuilder('o')
            ->addSelect('c')
            ->innerJoin('o.customer', 'c')
            ->andWhere('o.status = :status')
            ->setParameter('status', OrderStatus::Active)
            ->orderBy('o.createdAt', 'DESC')
            ->setMaxResults($limit)
            ->getQuery()
            ->getResult();

        return $orders;
    }
}
