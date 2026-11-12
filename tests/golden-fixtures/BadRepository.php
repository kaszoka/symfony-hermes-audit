<?php

namespace App\Repository;

use App\Entity\Order;
use Doctrine\ORM\EntityRepository;

// GOLDEN FIXTURE: Extends EntityRepository instead of ServiceEntityRepository
class BadRepository extends EntityRepository
{
    // DEFECT 1: Missing return type and array shape
    public function getActiveOrdersWithCustomer()
    {
        // DEFECT 2: findAll() with PHP memory filtering!
        $all = $this->findAll();
        $res = [];

        foreach ($all as $item) {
            // DEFECT 3: Non-Yoda comparison
            if ($item->getStatus() == 'active') {
                // DEFECT 4: N+1 query loop!
                $res[] = [
                    'id' => $item->getId(),
                    'customer' => $item->getCustomer()->getEmail(),
                ];
            }
        }

        return $res;
    }
}
