<?php

namespace App\Controller;

use App\Entity\Product;
use App\Entity\Review;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\DependencyInjection\Attribute\Required;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Psr\Log\LoggerInterface;

// GOLDEN FIXTURE: Known bad controller violating multiple Symfony Best Practices
class BadController extends AbstractController
{
    private LoggerInterface $logger;

    // DEFECT 1: Combining constructor injection with #[Required]
    public function __construct(private EntityManagerInterface $em)
    {
    }

    #[Required]
    public function setLogger(LoggerInterface $logger): void
    {
        $this->logger = $logger;
    }

    #[Route('/api/bad/products/{id}/review', methods: ['POST'])]
    public function createReview(int $id, Request $request): JsonResponse
    {
        // DEFECT 2: Service Locator in controller (getParameter without app. prefix)
        $maxRating = $this->getParameter('max_rating');

        // DEFECT 3: Manual request parsing instead of #[MapRequestPayload]
        $payload = $request->request->all();

        // DEFECT 4: Non-Yoda condition
        if ($payload['rating'] == null || $payload['rating'] > $maxRating) {
            // DEFECT 5: Exception formatting without sprintf, backticks, $request::class
            throw new \InvalidArgumentException('Field `rating` is invalid for ' . $request::class);
        } else {
            // DEFECT 6: else after throw
            // DEFECT 7: Service locator $em->getRepository()
            $product = $this->em->getRepository(Product::class)->find($id);
            if ($product === null) {
                throw $this->createNotFoundException('Product not found');
            }

            $review = new Review();
            $review->setProduct($product);
            // DEFECT 8: Error silencing operator @
            $review->setComment((string) @$payload['comment']);

            $this->em->persist($review);
            $this->em->flush();

            return new JsonResponse(['status' => 'ok']);
        }
    }
}
